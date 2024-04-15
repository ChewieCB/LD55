extends Node2D

signal cleansed

@onready var anim_player = $AnimationPlayer
@onready var particles = $GPUParticles2D
@onready var cleanse_ui = $CleanseBar
@onready var cleanse_sfx_1: AudioStream = load("res://assets/sfx/cleanse/Angelic_Chant_1.mp3")
@onready var cleanse_sfx_2: AudioStream = load("res://assets/sfx/cleanse/Angelic_Chant_2.mp3")
@onready var cleanse_sfx = [cleanse_sfx_1, cleanse_sfx_2]
@onready var ritual_sfx: AudioStream = load("res://assets/sfx/ritual/Control Point Draining 1.mp3")


var cleanse_progress: float = 0:
	set(value):
		cleanse_progress = clamp(value, 0, 100)
		if cleanse_progress == 100:
			cleanse()


func _process(_delta):
	cleanse_ui.value = cleanse_progress


func cleanse():
	anim_player.play("cleansing")
	SoundManager.play_sound(ritual_sfx)


func cleanse_complete():
	# TODO - add buffs to crusader/update loss counter/UI
	SoundManager.stop_sound(ritual_sfx)
	SoundManager.play_sound(cleanse_sfx[randi_range(0, cleanse_sfx.size() - 1)])
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

