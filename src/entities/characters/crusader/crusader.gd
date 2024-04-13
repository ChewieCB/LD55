extends AIAgent
class_name Crusader

signal cleansing_complete

var path: Curve2D
var path_points: PackedVector2Array
var path_index: int = 0
var ritual_point:
	set(value):
		ritual_point = value


func _move(delta):
	# If we're in range of a ritual point, move to that
	print(ritual_point)
	if ritual_point:
		nav_agent.target_position = ritual_point
	else:
		# Otherwise we move to the next path node
		nav_agent.target_position = path_points[path_index]
	
	if nav_agent.is_navigation_finished():
		if ritual_point:
			return
		path_index += 1
		nav_agent.target_position = path_points[path_index]
		return
	
	var current_agent_position: Vector2 = global_position
	var next_path_position: Vector2 = nav_agent.get_next_path_position()
	var direction: Vector2 = current_agent_position.direction_to(next_path_position)
	var intended_velocity: Vector2 = direction * speed
	nav_agent.set_velocity(intended_velocity)


func start_cleanse(ritual_node):
	cleansing_complete.connect(ritual_node.cleanse)
	await get_tree().create_timer(1.5).timeout
	emit_signal("cleansing_complete")
	finish_cleanse()


func finish_cleanse():
	ritual_point = null
	
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
