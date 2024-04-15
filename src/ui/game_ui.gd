extends Control
class_name GameUI

@onready var spell_ui: SpellUI = $SpellUI
@onready var time_panel: Label = $TimePanel/Label

@onready var health_bar: TextureProgressBar = $CrusaderHealthContainer/VBoxContainer/MarginContainer2/MarginContainer/HealthBar
@onready var damage_bar: TextureProgressBar = $CrusaderHealthContainer/VBoxContainer/MarginContainer2/MarginContainer/HealthBar/DamageBar
@onready var damage_timer: Timer = $CrusaderHealthContainer/VBoxContainer/MarginContainer2/MarginContainer/HealthBar/Timer

var health: int = 0: set = _set_health
var initialised: bool = false

func _set_health(value):
	if not initialised:
		return
	var prev_health = health
	health = min(health_bar.max_value, value)
	health_bar.value = health

	if health < prev_health:
		damage_timer.start()
	else:
		damage_bar.value = health

func init_health(_health):
	health = _health
	health_bar.max_value = _health
	health_bar.value = _health
	damage_bar.max_value = _health
	damage_bar.value = _health
	initialised = true

func _ready() -> void:
	GameManager.game_ui = self

func _on_timer_timeout():
	damage_bar.value = health
