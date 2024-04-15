extends Control
class_name SettingUI

@onready var master_slider: HSlider = $AudioSection/MasterLabel/MasterSlider
@onready var bgm_slider: HSlider = $AudioSection/BGMLabel/BGMSlider
@onready var sfx_slider: HSlider = $AudioSection/SFXLabel/SFXSlider

var is_starting_up = true

func _ready() -> void:
	GameManager.setting_ui = self
	visible = false
	master_slider.value = SoundManager.get_master_volume() * 100
	bgm_slider.value = SoundManager.get_music_volume() * 100
	sfx_slider.value = SoundManager.get_sound_volume() * 100
	is_starting_up = false

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("open_setting"):
		visible = not visible
		play_ui_click_sfx()

func _on_close_button_pressed() -> void:
	play_ui_click_sfx()
	visible = false

func _on_back_menu_button_pressed() -> void:
	play_ui_click_sfx()
	get_tree().change_scene_to_file("res://src/levels/main_scene/MainScene.tscn")
	
func _on_sfx_slider_value_changed(value: float) -> void:
	if not is_starting_up:
		play_ui_click_sfx()
	SoundManager.set_sound_volume(value / 100)

func _on_bgm_slider_value_changed(value: float) -> void:
	if not is_starting_up:
		play_ui_click_sfx()
	SoundManager.set_music_volume(value / 100)

func _on_master_slider_value_changed(value: float) -> void:
	if not is_starting_up:
		play_ui_click_sfx()
	SoundManager.set_master_volume(value / 100)

func play_ui_hover_sfx():
	Utils.play_button_hover_sfx()

func play_ui_click_sfx():
	Utils.play_button_click_sfx()
