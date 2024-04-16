extends Node

@onready var bgm: AudioStream = load("res://assets/music/LD55_Medley_1.0.mp3")
@onready var win_sfx: AudioStream = load("res://assets/sfx/ui/win_lose_states/You_Win_1_Laughing.mp3")
@onready var lose_sfx: AudioStream = load("res://assets/sfx/ui/win_lose_states/You_Die_Better_version.mp3")

signal game_ended

var player_control: PlayerControl
var game_ui: GameUI
var main_game: MainGame
var endgame_ui: EndgameUI
var crusader: Crusader
var setting_ui: SettingUI

# setting saved here to persist across screen
var scanline_enabled = true
var weather_enabled = true
var rain_enabled = true
var abberation_enabled = true

func _ready():
	SoundManager.play_music(bgm, 0.0, "Music")


func spawn_minion(minion: MinionBase):
	minion.crusader = crusader
	main_game.minion_spawn.add_child(minion)

func end_game(victory: bool):
	emit_signal("game_ended")
	if victory:
		await crusader.anim_player.animation_finished
		endgame_ui.show_win_screen()
		SoundManager.play_sound(win_sfx)
	else:
		endgame_ui.show_lose_screen()
		SoundManager.play_sound(lose_sfx)
