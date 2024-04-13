extends AIAgent
class_name MinionBase

@onready var cooldown_timer: Timer = $AttackCooldownTimer
@onready var health_ui = $HealthBar
@onready var state_chart: StateChart = $StateChart
# TODO - move this to parent class
@onready var anim_player = $AnimationPlayer
@onready var attack_particles = $AttackParticles
var crusader: Crusader
var crusader_target: Vector2


func _spawn():
	# TODO - play some animation or effect before beginning the movement
	health_ui.max_value = attributes.health
	if attacks:
		current_attack = attacks[0]


func _process(delta):
	health_ui.value = current_health


# TODO - this whole function can just be generic in the base class
func _attack(attack: AttackResource, target: AIAgent):
	attack_particles.global_position = target.global_position
	anim_player.play("attack")
	target.current_health -= attack.damage
	state_chart.send_event("finish_attack")
	await attack_particles.finished
	attack_particles.global_position = Vector2.ZERO


func _die():
	state_chart.send_event("stop_walking")
	state_chart.send_event("death")


func _on_idle_state_entered():
	nav_agent.target_position = global_position


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


func _on_attacking_idle_state_physics_processing(delta):
	# FIXME - dependency issue here with the crusader node not loading before this
	if cooldown_timer.is_stopped():
		if crusader.current_health > 0:
			if global_position.distance_to(crusader.global_position) <= current_attack.range:
				state_chart.send_event("stop_walking")
				state_chart.send_event("attack")


func _on_attacking_basic_attack_state_entered():
	_attack(current_attack, crusader)
	cooldown_timer.start(current_attack.cooldown)



func _on_dead_state_entered():
	anim_player.play("death")
	await anim_player.animation_finished
	queue_free()
