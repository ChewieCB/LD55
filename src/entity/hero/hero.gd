extends CharacterBody2D
class_name Hero

@export var patrol_path: Path2D

var move_speed = 100
var patrol_points: PackedVector2Array
var patrol_index = 0

func _ready():
	GameManager.hero = self
	if patrol_path:
		patrol_points = patrol_path.curve.get_baked_points()

func _physics_process(_delta: float):
	if !patrol_path:
		return
	var target = patrol_points[patrol_index]
	if position.distance_to(target) < 1:
		patrol_index = wrapi(patrol_index + 1, 0, patrol_points.size())
		target = patrol_points[patrol_index]
	velocity = (target - position).normalized() * move_speed
	move_and_slide()