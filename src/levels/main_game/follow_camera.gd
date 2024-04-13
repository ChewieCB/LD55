extends Camera2D

@export var player: CharacterBody2D

func _process(_delta: float) -> void:
	global_position = player.global_position
