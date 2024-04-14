extends Node2D

@onready var intro_cutscene: TabContainer = $CanvasLayer/Cutscene

var max_tab: int

func _ready():
	BuildThumbnail.capture_viewport()
	max_tab = intro_cutscene.get_tab_count()
	intro_cutscene.visible = false
	intro_cutscene.current_tab = 0

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("left_click") and intro_cutscene.visible:
		if intro_cutscene.current_tab < max_tab - 1:
			intro_cutscene.current_tab += 1
		else:
			get_tree().change_scene_to_file("res://src/levels/main_game/MainGame.tscn")

func _on_start_button_pressed() -> void:
	intro_cutscene.visible = true
