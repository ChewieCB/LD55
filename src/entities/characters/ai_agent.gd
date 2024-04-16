extends CharacterBody2D
class_name AIAgent

signal health_changed(health)
signal health_diff(diff)

@export var resource_attributes: CharacterAttributes:
	set(value):
		resource_attributes = value
		# Duplicate the resource so we can modify an individual 
		#  minion's attributes without changing all of them.
		attributes = resource_attributes.duplicate()
		current_health = attributes.health
		current_speed = attributes.speed
		current_armour = attributes.armour
		current_strength = attributes.strength
var attributes: CharacterAttributes

var current_health: int:
	set(value):
		var prev_health = current_health
		current_health = clamp(value, 0, attributes.health)
		emit_signal("health_diff", current_health - prev_health)
		emit_signal("health_changed", current_health)
		if current_health == 0:
			_die()
		elif value < prev_health:
			_hurt()
var current_speed: float
var current_armour: float
var current_strength: float
var acceleration: float = 7

@export var attacks: Array[AttackResource]
var current_attack: AttackResource
var in_cooldown: Array[AttackResource]
var cooldown_timers: Array
var priority_targets = []

@onready var nav_agent = $NavigationAgent2D
@onready var state_chart: StateChart = $StateChart
@onready var anim_player: AnimationPlayer = $AnimationPlayer

@onready var attack_range_area = $AttackRange
@onready var attack_range_collider = $AttackRange/CollisionShape2D

@onready var attack_particles: GPUParticles2D = $AttackParticles
@onready var block_particles: GPUParticles2D = $BlockParticles
@onready var death_particles: GPUParticles2D = $DeathParticles

@onready var buildup_timer = $AttackBuildupTimer
@onready var cooldown_timer = $AttackCooldownTimer
@onready var stagger_stun_timer = $StaggerStunTimer

@onready var health_ui = $HealthBar
@onready var status_ui = $StatusUI

func _ready():
	# This to make sure all NavigationServer stuff is synced
	process_mode = Node.PROCESS_MODE_DISABLED
	await get_tree().physics_frame
	call_deferred("_wait_for_navigation_setup")
	
	health_diff.connect(status_ui._spawn_damage_indicator)
	
	_spawn()

func _wait_for_navigation_setup():
	await get_tree().physics_frame
	process_mode = Node.PROCESS_MODE_INHERIT

func _physics_process(delta):
	_move(delta)

func _spawn():
	resource_attributes.play_summon_sfx()

func _move(_delta):
	if nav_agent.is_navigation_finished():
		return

	var current_agent_position: Vector2 = global_position
	var next_path_position: Vector2 = nav_agent.get_next_path_position()
	var direction: Vector2 = current_agent_position.direction_to(next_path_position)
	var intended_velocity: Vector2 = direction * current_speed
	nav_agent.set_velocity(intended_velocity)

func _attack(attack: AttackResource):
	# Update the attack area
	attack_range_collider.shape.radius = attack.attack_range
	await get_tree().physics_frame
	
	# Get targets
	var targets = attack.get_targets(self)
	
	state_chart.send_event("finish_attack")
	
	if targets:
		#
		var particles = GPUParticles2D.new()
		particles.amount = 1
		particles.speed_scale = 2
		particles.process_material = attack.attack_particles_process_mat
		particles.material = attack.attack_particles_canvas_mat
		particles.texture = attack.particle_texture
		particles.one_shot = true
		
		if attack.targeting_mode == AttackResource.TargetingMode.SINGLE:
			var _target = targets.front()
			# TODO - work out scale
			#attack_particles.scale = attack.attack_range
			_target.add_child(particles)
		elif attack.targeting_mode == AttackResource.TargetingMode.MULTIPLE:
			for _target in targets:
				var _particles_clone = particles.duplicate()
				_target.add_child(_particles_clone)
				_particles_clone.finished.connect(
					func(): 
					particles.queue_free()
				)
				particles.queue_free()
		else:
			add_child(particles)
		
		if particles:
			particles.finished.connect(
				func(): 
				particles.queue_free()
			)
		
		var target_count: int = 0
		for target in targets:
			if target.current_health <= 0:
				if target in priority_targets:
					priority_targets.erase(target)
				continue
			
			if attack.targeting_mode == AttackResource.TargetingMode.MULTIPLE:
				if target_count >= attack.max_targets:
					break
			
			# Calculate stagger or stun chance
			# We need to pass 0.5 to stagger, and 0.9 to stun
			# TODO - playtest and tweak this
			var stagger_chance = clamp(
				(0.8 - randf()) + attack.control,# + target.attributes.dexterity,
				0.0,
				1.0
			)
			if stagger_chance >= 0.9:
				target._stun()
			elif stagger_chance >= 0.5:
				target._stagger()
				
			# Damage and armour penetration
			# TODO - playtest and tweak armour damage reduction 
			var modified_damage = attack.damage * attributes.strength
			# TODO - figure out an intuitive armour/armour penetration system
			if attack.armour_penetration < target.attributes.armour:
				modified_damage = clamp(
					modified_damage / target.attributes.armour,
					0,
					modified_damage
				)
			target.current_health -= modified_damage
			
			if modified_damage > 0:
				# TODO - spawn a particle emitter for each attack instance
				particles.emitting = true
				#anim_player.play("attack")
				attack.play_attack_sfx()
			else:
				anim_player.play("block")
				attack.play_block_sfx()
			
			target_count += 1
	
		_attack_cooldown(attack)
		#status_ui._spawn_attack_indicator(attack.name, 0.6)
		current_attack = null
		
		# Generic cooldown to prevent spamming inputs each frame
		cooldown_timer.start(0.4)

func _attack_cooldown(attack: AttackResource):
	in_cooldown.append(attack)
	var cd_timer = get_tree().create_timer(
		attack.cooldown * remap(attributes.dexterity, 0, 1, 3, 0.25)
	)
	cooldown_timers.append(cd_timer)
	
	await cd_timer.timeout
	
	in_cooldown.erase(attack)
	cooldown_timers.erase(cd_timer)

func is_in_cooldown(attack: AttackResource):
	return in_cooldown.has(attack)

func _stagger():
	state_chart.send_event("stagger")

func _stun():
	state_chart.send_event("stun")

func _hurt():
	pass

func _die():
	pass

func _on_navigation_agent_2d_velocity_computed(safe_velocity):
	velocity = safe_velocity
	move_and_slide()
