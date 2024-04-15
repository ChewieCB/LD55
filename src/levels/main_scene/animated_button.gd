extends Button

@export var h_offset: int = -40
@export var v_offset: int = 0
@export var duration: float = 0.3

var original_pos: Vector2
var tween

func _ready() -> void:
	original_pos = global_position
	self.mouse_entered.connect(start_animate)
	self.mouse_exited.connect(back_to_normal)

func start_animate():
	if disabled:
		return
	if tween:
		tween.kill()

	tween = get_tree().create_tween()
	tween.tween_property(self, "global_position", original_pos + Vector2(h_offset, v_offset), duration).set_trans(Tween.TRANS_LINEAR)

func back_to_normal():
	if disabled:
		return
	if tween:
		tween.kill()

	tween = get_tree().create_tween()
	tween.tween_property(self, "global_position", original_pos, duration).set_trans(Tween.TRANS_LINEAR)