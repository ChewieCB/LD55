extends Control
class_name EndgameUI

@onready var tab_container: TabContainer = $TabContainer

func _ready():
	visible = false
	GameManager.endgame_ui = self

func show_win_screen():
	visible = true
	get_tree().paused = true
	tab_container.current_tab = 0

func show_lose_screen():
	visible = true
	get_tree().paused = true
	tab_container.current_tab = 1

func _on_menu_button_pressed():
	get_tree().change_scene_to_file("res://src/levels/main_scene/MainScene.tscn")

func _on_play_button_pressed():
	get_tree().reload_current_scene()
