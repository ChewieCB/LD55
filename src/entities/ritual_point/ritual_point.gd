extends Node2D


func cleanse():
	# TODO - add buffs to crusader/update loss counter/UI
	queue_free()


func _on_range_body_entered(body):
	if body is Crusader:
		body.ritual_point = global_position


func _on_cleansing_area_body_entered(body):
	if body is Crusader:
		body.ritual_point = body.global_position
		body.start_cleanse(self)

