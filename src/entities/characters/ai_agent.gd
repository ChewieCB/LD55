extends CharacterBody2D
class_name AIAgent

signal health_changed(change)

@export var attributes: CharacterAttributes:
	set(value):
		attributes = value
		current_health = attributes.health
		current_speed = attributes.speed

var current_health: int:
	set(value):
		var prev_health = current_health
		current_health = clamp(value, 0, attributes.health)
		emit_signal("health_changed", current_health - prev_health)
		if current_health == 0:
			_die()
		elif value < prev_health:
			_hurt()
		elif value == prev_health:
			# TODO - add new particle effect for blocking
			#_block()
			pass
var current_speed: float
var acceleration: float = 7

@export var attacks: Array[AttackResource]
var current_attack: AttackResource

@onready var nav_agent = $NavigationAgent2D
@onready var state_chart: StateChart = $StateChart
@onready var anim_player: AnimationPlayer = $AnimationPlayer

@onready var attack_particles: GPUParticles2D = $AttackParticles
@onready var block_particles: GPUParticles2D = $BlockParticles
@onready var death_particles: GPUParticles2D = $DeathParticles

@onready var cooldown_timer = $AttackCooldownTimer
@onready var stagger_stun_timer = $StaggerStunTimer

@onready var health_ui = $HealthBar
@onready var status_ui = $StatusUI

func _ready():
	#await get_owner().ready
	health_changed.connect(status_ui._spawn_damage_indicator)
	_spawn()

func _physics_process(delta):
	_move(delta)

func _spawn():
	pass

func _move(_delta):
	if nav_agent.is_navigation_finished():
		return

	var current_agent_position: Vector2 = global_position
	var next_path_position: Vector2 = nav_agent.get_next_path_position()
	var direction: Vector2 = current_agent_position.direction_to(next_path_position)
	var intended_velocity: Vector2 = direction * current_speed
	nav_agent.set_velocity(intended_velocity)

func _attack(attack: AttackResource, target: AIAgent):
	attack_particles.global_position = target.global_position
	block_particles.global_position = target.global_position

	# Calculate stagger or stun chance
	# We need to pass 0.5 to stagger, and 0.9 to stun
	# TODO - playtest and tweak this
	var stagger_chance = clamp(
		(0.8 - randf()) + attack.control + target.attributes.dexterity,
		0.0,
		1.0
	)
	if stagger_chance >= 0.9:
		target._stun()
	elif stagger_chance >= 0.5:
		target._stagger()

	# Damage and armour penetration
	# TODO - playtest and tweak armour damage reduction
	var modified_damage = attack.damage
	# TODO - figure out an intuitive armour/armour penetration system
	if attack.armour_penetration < target.attributes.armour:
		modified_damage = clamp(
			attack.damage / float(target.attributes.armour),
			0,
			attack.damage
		)
	target.current_health -= modified_damage

	if modified_damage > 0:
		anim_player.play("attack")
	else:
		anim_player.play("block")

	state_chart.send_event("finish_attack")

	await attack_particles.finished
	attack_particles.global_position = Vector2.ZERO

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
