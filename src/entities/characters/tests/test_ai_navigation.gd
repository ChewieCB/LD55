extends Node2D

@onready var agents_node = $Agents

var target_point:
	set(value):
		target_point = value
		for agent in agents_node.get_children():
			agent.nav_agent.target_position = target_point


func _draw():
	if target_point:
		draw_circle(target_point, 10, Color.RED)


func _process(delta):
	queue_redraw()


func _input(event):
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
			target_point = event.global_position
