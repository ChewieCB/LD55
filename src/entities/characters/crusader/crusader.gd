extends AIAgent
class_name Crusader

signal cleansing_complete

@onready var state_chart: StateChart = $StateChart
@onready var health_ui = $HealthBar
@onready var anim_player = $AnimationPlayer

var path: Curve2D
var path_points: PackedVector2Array
var path_index: int = 0:
	set(value):
		if value > path_points.size() - 1:
			path_index = path_points.size() - 1
		else:
			path_index = value
var ritual_point:
	set(value):
		ritual_point = value


func _spawn():
	# TODO - play some animation or effect before beginning the movement
	health_ui.max_value = attributes.health


func _process(delta):
	health_ui.value = current_health


func _hurt():
	state_chart.send_event("take_damage")


func _die():
	state_chart.send_event("death")


func start_cleanse(ritual_node):
	cleansing_complete.connect(ritual_node.cleanse)
	state_chart.send_event("stop_walking")
	state_chart.send_event("start_cleansing")


func finish_cleanse():
	ritual_point = null
	# TODO - remove this after debugging
	current_health -= 150
	
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


func _on_idle_state_physics_processing(delta):
	if nav_agent.target_position:
		state_chart.send_event("start_walking")
	return


func _on_walking_state_physics_processing(delta):
	# If we're in range of a ritual point, move to that
	if ritual_point:
		nav_agent.target_position = ritual_point
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
	await get_tree().create_timer(1.5).timeout
	finish_cleanse()


func _on_hit_state_entered():
	anim_player.play("hurt")
	await anim_player.animation_finished
	state_chart.send_event("end_damage")


func _on_dead_state_entered():
	#anim_player.play("death")
	pass # Replace with function body.
