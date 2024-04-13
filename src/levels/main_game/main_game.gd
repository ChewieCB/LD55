extends Node2D
class_name MainGame

@onready var patrol_path = $Ground/Path2D
@onready var minion_spawn = $Minions
@onready var crusader = $Crusader



func _ready() -> void:
	GameManager.main_game = self
	crusader.path = patrol_path.curve
	crusader.path_points = patrol_path.curve.get_baked_points()
	
	for minion in minion_spawn.get_children():
		minion.crusader = crusader
