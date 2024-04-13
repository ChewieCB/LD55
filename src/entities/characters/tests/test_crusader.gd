extends Node2D

@onready var crusader = $Crusader
@onready var patrol_path = $Path2D
var patrol_points: PackedVector2Array


func _ready():
	if patrol_path:
		crusader.path = patrol_path.curve
		crusader.path_points = patrol_path.curve.get_baked_points()
	
	for minion in $Minions.get_children():
		minion.crusader = $Crusader
