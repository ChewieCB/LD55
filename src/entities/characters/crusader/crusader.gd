extends AIAgent
class_name Crusader

signal cleansing_complete
signal death

# TODO - map this to an enum that matches the attack names
enum AttackNames {
	BASIC_ATTACK,
	SPIN,
	AOE,
	CLEAVE,
	SMITE,
}

enum Stance {
	FAST,
	TANK,
	DAMAGE
}

var current_stance: Stance = Stance.FAST

# TODO - move to AIAgent base class
@onready var buildup_bar = $AttackBuildup

var path: Curve2D
var path_points: PackedVector2Array
var path_index: int = 0:
	set(value):
		if value > path_points.size() - 1:
			path_index = path_points.size() - 1
		else:
			path_index = value
var ritual_point: Node2D:
	set(value):
		ritual_point = value

func _spawn():
	GameManager.crusader = self
	# TODO - play some animation or effect before beginning the movement
	health_ui.max_value = attributes.health
	add_to_group("crusader")

func _process(_delta):
	health_ui.value = current_health

func _hurt():
	state_chart.send_event("take_damage")

func _die():
	state_chart.send_event("stop_walking")
	state_chart.send_event("stop_cleansing")
	state_chart.send_event("death")

func start_cleanse(ritual_node):
	cleansing_complete.connect(ritual_node.cleanse_complete)
	state_chart.send_event("stop_walking")
	state_chart.send_event("start_cleansing")

func finish_cleanse():
	ritual_point = null
	emit_signal("cleansing_complete")

	var path_points_sorted_closest = Array(path_points)
	path_points_sorted_closest.sort_custom(
		func(a, b):
			if a.distance_to(global_position) < b.distance_to(global_position):
				return true
			return false
	)
	var closest_path_point = path_points_sorted_closest[0]

	path_index = path_points.find(closest_path_point)
	nav_agent.target_position = closest_path_point

	state_chart.send_event("stop_cleansing")

func _on_idle_state_entered():
	nav_agent.target_position = global_position

func _on_idle_state_physics_processing(_delta):
	if nav_agent.target_position:
		state_chart.send_event("start_walking")
	return

func _on_walking_state_physics_processing(_delta):
	# If we're in range of a ritual point, move to that
	if ritual_point:
		nav_agent.target_position = ritual_point.global_position
	else:
		# Otherwise we move to the next path node
		nav_agent.target_position = path_points[path_index]

	if nav_agent.is_navigation_finished():
		if ritual_point:
			state_chart.send_event("stop_walking")
			return
		path_index += 1
		nav_agent.target_position = path_points[path_index]
		return

	var current_agent_position: Vector2 = global_position
	var next_path_position: Vector2 = nav_agent.get_next_path_position()
	var direction: Vector2 = current_agent_position.direction_to(next_path_position)
	var intended_velocity: Vector2 = direction * current_speed
	nav_agent.set_velocity(intended_velocity)

func _on_action_idle_state_entered():
	state_chart.send_event("start_walking")

func _on_action_cleansing_state_entered():
	ritual_point.cleanse()

func _on_action_cleansing_state_physics_processing(delta):
	while ritual_point.cleanse_progress < 100:
		ritual_point.cleanse_progress += delta * 15
		return
	finish_cleanse()


func _on_default_stance_state_entered():
	current_speed = attributes.speed * 1.7


func _on_default_stance_state_physics_processing(delta):
	# For dealing with hordes, lots of fast, low damage attacks with many targets
	#
	# Generic cooldown for all attacks
	if not cooldown_timer.is_stopped():
		return
	
	var attack_priority = [
		attacks[AttackNames.AOE],
		attacks[AttackNames.SPIN],
		attacks[AttackNames.BASIC_ATTACK]
	]
	for _attack in attack_priority:
		if not is_in_cooldown(_attack):
			current_attack = _attack
			break
	
	if current_attack:
		if attack_range_area.has_overlapping_bodies():
			state_chart.send_event("stop_walking")
			state_chart.send_event("attack")
			return


func _on_default_stance_state_exited():
	current_speed = attributes.speed


func _on_tank_stance_state_entered():
	current_speed = attributes.speed * 0.35
	current_armour = attributes.armour * 2


func _on_tank_stance_state_physics_processing(delta):
	# For dealing with elites, move slowly, increase armour
	#
	# Generic cooldown for all attacks
	if not cooldown_timer.is_stopped():
		return
	
	var attack_priority = [
		attacks[AttackNames.SMITE],
		attacks[AttackNames.CLEAVE],
		attacks[AttackNames.BASIC_ATTACK]
	]
	for _attack in attack_priority:
		if not is_in_cooldown(_attack):
			current_attack = _attack
			break
	
	if current_attack:
		if attack_range_area.has_overlapping_bodies():
			state_chart.send_event("stop_walking")
			state_chart.send_event("attack")
			return


func _on_tank_stance_state_exited():
	current_speed = attributes.speed
	current_armour = attributes.armour


func _on_attacking_idle_state_entered():
	# TODO - remove random switching, replace with target type checks
	if randf_range(0, 1) > 0.65:
		var stance_str: String
		match current_stance:
			Stance.FAST:
				stance_str = "tank_stance"
				$StanceLabel.text = "Tank"
				current_stance = Stance.TANK
			Stance.TANK:
				stance_str = "default_stance"
				$StanceLabel.text = "Fast"
				current_stance = Stance.FAST
			Stance.DAMAGE:
				stance_str = "damage_stance"
				$StanceLabel.text = "Damage"
		state_chart.send_event(stance_str)


func _on_attacking_idle_state_physics_processing(delta):
	pass
	# FIXME - get buildup/cooldown UI working again and handle it here
	# Generic cooldown for all attacks
	#if not cooldown_timer.is_stopped():
		#return
	#
	#var attack_priority = [
		#attacks[AttackNames.AOE],
		#attacks[AttackNames.SPIN],
		#attacks[AttackNames.BASIC_ATTACK]
	#]
	#for _attack in attack_priority:
		#if not is_in_cooldown(_attack):
			#current_attack = _attack
			#break
	#
	#if current_attack:
		#if attack_range_area.has_overlapping_bodies():
			#state_chart.send_event("stop_walking")
			#state_chart.send_event("attack")
			#return
		#else:
			#var cooldown_timer_idx = in_cooldown.find(current_attack)
			#if cooldown_timer_idx != -1:
				#var cooldown_timer = cooldown_timers[cooldown_timer_idx]
				#var max_cooldown_time = current_attack.cooldown * remap(
					#attributes.dexterity, 0, 1, 3, 0.25
				#)
				#buildup_bar.value = remap(
					#cooldown_timer.time_left,
					#max_cooldown_time, 0,
					#0, 100
				#)


func _on_attacking_buildup_state_entered():
	buildup_bar.value = 0
	buildup_timer.start(current_attack.attack_delay)


func _on_buildup_state_physics_processing(delta):
	if not buildup_timer.is_stopped():
		buildup_bar.value = remap(
			buildup_timer.time_left / current_attack.attack_delay,
			0.0, current_attack.attack_delay,
			0, 100
		)

func _on_attacking_buildup_state_exited():
	buildup_bar.value = 0
	buildup_timer.stop()


func _on_attacking_attack_state_entered():
	if is_in_cooldown(current_attack):
		state_chart.send_event("finish_attack")
		return
	
	_attack(current_attack)
	buildup_bar.value = 100


func _on_hit_state_entered():
	anim_player.play("hurt")
	await anim_player.animation_finished
	state_chart.send_event("end_damage")

func _on_dead_state_entered():
	state_chart.send_event("stop_walking")
	#anim_player.play("death")
	emit_signal("death")

func _on_minion_attack_area_body_entered(body):
	if body is MinionBase:
		body.crusader_target = body.global_position

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


func _on_attack_buildup_timer_timeout():
	state_chart.send_event("perform_attack")

