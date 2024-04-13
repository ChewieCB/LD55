extends Node2D

signal cleansed

@onready var anim_player = $AnimationPlayer
@onready var particles = $GPUParticles2D
@onready var cleanse_ui = $CleanseBar

var cleanse_progress: float = 0:
	set(value):
		cleanse_progress = clamp(value, 0, 100)
		if cleanse_progress == 100:
			cleanse()


func _process(delta):
	cleanse_ui.value = cleanse_progress


func cleanse():
	anim_player.play("cleansing")


func cleanse_complete():
	# TODO - add buffs to crusader/update loss counter/UI
	anim_player.play("cleanse_complete")
	await particles.finished
	emit_signal("cleansed")
	queue_free()


func _on_range_body_entered(body):
	if body is Crusader:
		body.ritual_point = self


func _on_cleansing_area_body_entered(body):
	if body is Crusader:
		#body.ritual_point = body.global_position
		body.start_cleanse(self)

