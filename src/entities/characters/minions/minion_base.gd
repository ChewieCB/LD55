extends AIAgent
class_name MinionBase

var crusader: Crusader
var crusader_target: Vector2

func _spawn():
	resource_attributes.play_summon_sfx()
	# TODO - play some animation or effect before beginning the movement
	health_ui.max_value = attributes.health
	if attacks:
		current_attack = attacks[0]
	anim_player.play("spawn")

func _process(_delta):
	health_ui.value = current_health


func _hurt():
	anim_player.play("hurt")

func _die():
	state_chart.send_event("stop_walking")
	state_chart.send_event("death")

func _on_idle_state_entered():
	nav_agent.target_position = global_position

func _on_idle_state_physics_processing(_delta):
	if nav_agent.target_position:
		# Wait for spawn anim to finish
		await anim_player.animation_finished
		state_chart.send_event("start_walking")
	return

func _on_walking_state_physics_processing(_delta):
	# FIXME - dependency issue here with the crusader node not loading before this
	if not crusader:
		return
	
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
	
	if crusader.current_health == 0:
		state_chart.send_event("finish_attack")
	
	# Generic cooldown for all attacks
	if not cooldown_timer.is_stopped():
		return
	
	# TODO - add attack choice logic in via stances
	# TODO - add attack name enum
	var attack_priority = attacks
	for elem in attack_priority:
		if not is_in_cooldown(elem):
			current_attack = elem
			break
	
	if current_attack:
		if global_position.distance_to(crusader.global_position) <= current_attack.attack_range:
			state_chart.send_event("stop_walking")
			state_chart.send_event("attack")
			return

func _on_attacking_basic_attack_state_entered():
	if is_in_cooldown(current_attack):
		state_chart.send_event("finish_attack")
		return
	
	_attack(current_attack)

func _on_dead_state_entered():
	anim_player.play("death")
	await anim_player.animation_finished
	queue_free()

func apply_prefix(prefix: EnumAutoload.SpellPrefix):
	match prefix:
		EnumAutoload.SpellPrefix.AGILE:
			attributes.speed *= 1.4
			attributes.dexterity *= 2.2
			scale *= 0.7
		EnumAutoload.SpellPrefix.TOUGH:
			attributes.health *= 2
			current_health = attributes.health
			scale *= 1.4

func _on_status_staggered_state_entered():
	status_ui._spawn_status_indicator("Staggered", 2.0)
	current_speed = attributes.speed * 0.25
	stagger_stun_timer.start(2.0)

func _on_status_staggered_state_exited():
	current_speed = attributes.speed

func _on_status_stunned_state_entered():
	# TODO - add dynamic status duration
	status_ui._spawn_status_indicator("Stunned", 2.0)
	current_speed = 0
	state_chart.send_event("stop_walking")
	stagger_stun_timer.start(2.0)

func _on_status_stunned_state_exited():
	current_speed = attributes.speed

func _on_stagger_stun_timer_timeout():
	state_chart.send_event("recover_stagger")
	state_chart.send_event("recover_stun")
