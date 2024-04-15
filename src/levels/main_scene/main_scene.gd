extends Node2D

@export var animated_buttons: Array[Button] = []

@onready var tutorial = $CanvasLayer/Tutorial
@onready var intro_cutscene: TabContainer = $CanvasLayer/Cutscene

var max_tab: int

func _ready():
	# BuildThumbnail.capture_viewport()
	for elem in animated_buttons:
		elem.disabled = true
	max_tab = intro_cutscene.get_tab_count()
	intro_cutscene.visible = false
	tutorial.visible = false
	intro_cutscene.current_tab = 0

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("left_click") and intro_cutscene.visible:
		if intro_cutscene.current_tab < max_tab - 1:
			Utils.play_button_click_sfx()
			intro_cutscene.current_tab += 1
		else:
			get_tree().change_scene_to_file("res://src/levels/main_game/MainGame.tscn")

func _on_start_button_pressed() -> void:
	Utils.play_button_click_sfx()
	intro_cutscene.visible = true

func _on_tutorial_button_pressed() -> void:
	Utils.play_button_click_sfx()
	tutorial.visible = not tutorial.visible
	
func _on_quit_button_pressed() -> void:
	Utils.play_button_click_sfx()
	get_tree().quit()

func play_ui_hover_sfx():
	Utils.play_button_hover_sfx()

func play_ui_click_sfx():
	Utils.play_button_click_sfx()

func finished_startup_animation():
	for elem in animated_buttons:
		elem.disabled = false
