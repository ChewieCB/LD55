extends AIAgent
class_name Crusader

signal cleansing_complete
signal death

@onready var attack_range_area = $AttackRange
@onready var attack_range_collider = $AttackRange/CollisionShape2D

@onready var _attack_sfx_1: AudioStream = load("res://assets/sfx/attacks/Blade_Impact.wav")
@onready var _attack_sfx_2: AudioStream = load("res://assets/sfx/attacks/Blade_Impact_2.wav")
@onready var attack_sfx = [_attack_sfx_1, _attack_sfx_2]

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
	if attacks:
		current_attack = attacks[0]
		attack_range_collider.shape.radius = current_attack.attack_range

func _process(_delta):
	health_ui.value = current_health

# TODO - this whole function can just be generic in the base class
func _attack(attack: AttackResource, target: AIAgent):
	attack_particles.global_position = target.global_position
	SoundManager.play_sound(attack_sfx[randi_range(0, attack_sfx.size() - 1)])
	anim_player.play("attack")
	target.current_health -= attack.damage
	state_chart.send_event("finish_attack")
	await attack_particles.finished
	attack_particles.global_position = Vector2.ZERO

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
	await get_tree().process_frame
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
	var intended_velocity: Vector2 = direction * speed
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

func _on_attacking_idle_state_physics_processing(_delta):
	if cooldown_timer.is_stopped():
		if attack_range_area.has_overlapping_bodies():
			state_chart.send_event("stop_walking")
			state_chart.send_event("attack")

func _on_attacking_basic_attack_state_entered():
	# Get target
	var minions = attack_range_area.get_overlapping_bodies()
	minions.sort_custom(
		func(a, b):
			if a.global_position.distance_to(global_position) < b.global_position.distance_to(global_position):
				return true
			return false
	)
	var target = minions.front()
	_attack(current_attack, target)
	cooldown_timer.start(current_attack.cooldown)

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
