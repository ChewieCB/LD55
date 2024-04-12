extends Node


func _unhandled_input(event):
	if Input.is_action_just_pressed("screenshot"):
		capture_viewport()


func capture_viewport():
	await RenderingServer.frame_post_draw
	var capture = get_viewport().get_texture().get_image()
	var _time = Time.get_datetime_string_from_system()
	var filename = "res://dist/screenshots/screenshot-{0}.png".format({"0": _time})
	capture.save_png(filename)
