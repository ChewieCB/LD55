extends Node

@onready var bgm: AudioStream = load("res://assets/music/Track2_0.0.0.mp3")

signal game_ended

var player_control: PlayerControl
var game_ui: GameUI
var main_game: MainGame
var endgame_ui: EndgameUI
var crusader: Crusader

func _ready():
	SoundManager.play_music(bgm)

func _input(_event):
	if Input.is_action_just_pressed("ui_cancel"):
		get_tree().change_scene_to_file("res://src/levels/main_scene/MainScene.tscn")

func end_game(victory: bool):
	emit_signal("game_ended")
	if victory:
		endgame_ui.show_win_screen()
	else:
		endgame_ui.show_lose_screen()