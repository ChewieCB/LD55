extends Node2D
class_name MainGame

@onready var game_area = $YSort

func _ready() -> void:
	GameManager.main_game = self
