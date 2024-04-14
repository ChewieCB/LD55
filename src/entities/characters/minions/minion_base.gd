extends AIAgent
class_name MinionBase

var crusader: Crusader
var crusader_target: Vector2

@onready var _minion_sfx_1: AudioStream = load("res://assets/sfx/minions/zombie/Zombie_Growl.mp3")
@onready var _minion_sfx_2: AudioStream = load("res://assets/sfx/minions/zombie/Zombie_Growl_2.mp3")
@onready var _minion_sfx_3: AudioStream = load("res://assets/sfx/minions/zombie/Zombie_Growl_3.mp3")
@onready var minion_sfx = [_minion_sfx_1, _minion_sfx_2, _minion_sfx_3]
#
@onready var _attack_sfx_1: AudioStream = load("res://assets/sfx/Magic_Impact.mp3")
@onready var attack_sfx = [_attack_sfx_1]


func _spawn():
	# TODO - play some animation or effect before beginning the movement
	health_ui.max_value = attributes.health
	if attacks:
		current_attack = attacks[0]
	SoundManager.play_sound(minion_sfx[randi_range(0, minion_sfx.size() - 1)])


func _process(_delta):
	health_ui.value = current_health


func _die():
	state_chart.send_event("stop_walking")
	state_chart.send_event("death")


func _on_idle_state_entered():
	nav_agent.target_position = global_position


func _on_idle_state_physics_processing(_delta):
	if nav_agent.target_position:
		state_chart.send_event("start_walking")
	return


func _on_walking_state_physics_processing(_delta):
	# FIXME - dependency issue here with the crusader node not loading before this
	crusader_target = crusader.global_position
	nav_agent.target_position = crusader_target
	
	if nav_agent.is_navigation_finished():
		return

	var current_agent_position: Vector2 = global_position
	var next_path_position: Vector2 = nav_agent.get_next_path_position()
	var direction: Vector2 = current_agent_position.direction_to(next_path_position)
	var intended_velocity: Vector2 = direction * current_speed
	nav_agent.set_velocity(intended_velocity)


func _on_attacking_idle_state_physics_processing(_delta):
	# FIXME - dependency issue here with the crusader node not loading before this
	if crusader == null: 
		return
	if cooldown_timer.is_stopped():
		if crusader.current_health > 0:
			if global_position.distance_to(crusader.global_position) <= current_attack.attack_range:
				state_chart.send_event("stop_walking")
				state_chart.send_event("attack")


func _on_attacking_basic_attack_state_entered():
	_attack(current_attack, crusader)
	SoundManager.play_sound(attack_sfx[randi_range(0, attack_sfx.size() - 1)])
	cooldown_timer.start(current_attack.cooldown * remap(attributes.dexterity, 0, 1, 3, 0.25))


func _on_dead_state_entered():
	anim_player.play("death")
	await anim_player.animation_finished
	queue_free()
