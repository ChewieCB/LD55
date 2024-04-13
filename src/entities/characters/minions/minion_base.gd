extends AIAgent
class_name MinionBase

@export var attacks: Array[AttackResource]
var current_attack: AttackResource

@onready var cooldown_timer: Timer = $AttackCooldownTimer
@onready var state_chart: StateChart = $StateChart
# TODO - move this to parent class
@onready var anim_player = $AnimationPlayer
@onready var attack_particles = $AttackParticles
var crusader: Crusader
var crusader_target: Vector2


func _spawn():
	# TODO - play some animation or effect before beginning the movement
	#health_ui.max_value = attributes.health
	await get_tree().physics_frame
	await get_tree().physics_frame
	crusader = get_tree().get_nodes_in_group("crusader")[0]
	if attacks:
		current_attack = attacks[0]
	
	cooldown_timer.timeout.connect(func(): print("cooldown"))


func _attack(attack: AttackResource):
	anim_player.play("attack")
	crusader.current_health -= attack.damage
	state_chart.send_event("finish_attack")


func _on_idle_state_physics_processing(delta):	
	if nav_agent.target_position:
		state_chart.send_event("start_walking")
	return


func _on_walking_state_physics_processing(delta):
	# FIXME - dependency issue here with the crusader node not loading before this
	crusader_target = crusader.global_position
	nav_agent.target_position = crusader_target
	
	if nav_agent.is_navigation_finished():
		return

	var current_agent_position: Vector2 = global_position
	var next_path_position: Vector2 = nav_agent.get_next_path_position()
	var direction: Vector2 = current_agent_position.direction_to(next_path_position)
	var intended_velocity: Vector2 = direction * speed
	nav_agent.set_velocity(intended_velocity)


func _on_basic_attack_state_entered():
	_attack(current_attack)
	cooldown_timer.start(current_attack.cooldown)


func _on_attacking_idle_state_physics_processing(delta):
	# FIXME - dependency issue here with the crusader node not loading before this
	if cooldown_timer.is_stopped():
		if crusader.current_health > 0:
			if global_position.distance_to(crusader.global_position) <= current_attack.range:
				state_chart.send_event("stop_walking")
				state_chart.send_event("attack")
