extends Node2D


# Called when the node enters the scene tree for the first time.
func _ready():
	BuildThumbnail.capture_viewport()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass


func _on_summoning_button_pressed():
	get_tree().change_scene_to_file("res://src/levels/main_game/MainGame.tscn")


func _on_crusader_ai_button_pressed():
	get_tree().change_scene_to_file("res://src/entities/characters/tests/TestCrusader.tscn")
