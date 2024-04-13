extends Control
class_name GameUI

@onready var spell_label: Label = $SpellPanel/Label
@onready var time_panel: Label = $TimePanel/Label

func _ready() -> void:
	GameManager.game_ui = self
	spell_label.text = "Press Space to start"

func set_spell_label(text: String):
	spell_label.text = text
