extends Node

@onready var bgm: AudioStream = load("res://assets/music/Track2_0.0.0.mp3")


func _ready():
	SoundManager.play_music(bgm)


func _input(event):
	if Input.is_action_just_pressed("ui_cancel"):
		get_tree().change_scene_to_file("res://src/levels/main_scene/MainScene.tscn")

var player_control: PlayerControl
var game_ui: GameUI
var main_game: MainGame
