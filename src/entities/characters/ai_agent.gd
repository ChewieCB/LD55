extends CharacterBody2D
class_name AIAgent

@export var attributes: CharacterAttributes:
	set(value):
		attributes = value
		current_health = attributes.health
		speed = attributes.speed

var current_health: int = 100
var speed: int = 300
var acceleration: int = 7

@onready var nav_agent = $NavigationAgent2D


func _spawn():
	# TODO
	pass


func _physics_process(delta):
	_move(delta)


func _move(delta):
	if nav_agent.is_navigation_finished():
		return
	
	var current_agent_position: Vector2 = global_position
	var next_path_position: Vector2 = nav_agent.get_next_path_position()
	var direction: Vector2 = current_agent_position.direction_to(next_path_position)
	var intended_velocity: Vector2 = direction * speed
	nav_agent.set_velocity(intended_velocity)


func _die():
	# TODO
	pass



func _on_navigation_agent_2d_velocity_computed(safe_velocity):
	velocity = safe_velocity
	move_and_slide()
