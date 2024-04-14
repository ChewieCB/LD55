extends Control
class_name GameUI

@onready var spell_ui: SpellUI = $SpellUI
@onready var time_panel: Label = $TimePanel/Label

func _ready() -> void:
	GameManager.game_ui = self
