extends CharacterBody2D
class_name AIAgent

@export var attributes: CharacterAttributes:
	set(value):
		attributes = value
		current_health = attributes.health
		speed = attributes.speed

var current_health: int:
	set(value):
		var prev_health = current_health
		current_health = clamp(value, 0, attributes.health)
		if current_health == 0:
			_die()
		elif value < prev_health:
			_hurt()
var speed: int
var acceleration: int = 7

@export var attacks: Array[AttackResource]
var current_attack: AttackResource

@onready var nav_agent = $NavigationAgent2D
@onready var state_chart: StateChart = $StateChart
@onready var anim_player: AnimationPlayer = $AnimationPlayer
@onready var attack_particles: GPUParticles2D = $AttackParticles
@onready var death_particles: GPUParticles2D = $DeathParticles
@onready var cooldown_timer = $AttackCooldownTimer

@onready var health_ui = $HealthBar

func _ready():
	#await get_owner().ready
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
	var intended_velocity: Vector2 = direction * speed
	nav_agent.set_velocity(intended_velocity)

func _attack(attack: AttackResource, target: AIAgent):
	attack_particles.global_position = target.global_position
	anim_player.play("attack")
	target.current_health -= attack.damage
	state_chart.send_event("finish_attack")
	await attack_particles.finished
	attack_particles.global_position = Vector2.ZERO

func _hurt():
	pass

func _die():
	pass

func _on_navigation_agent_2d_velocity_computed(safe_velocity):
	velocity = safe_velocity
	move_and_slide()
