extends Node2D

signal cleansed

@onready var anim_player = $AnimationPlayer
@onready var particles = $GPUParticles2D
@onready var cleanse_ui = $CleanseBar
@export var cleanse_sfx: Array[AudioStream]
var _cleanse_sfx_full = []
@onready var ritual_sfx: AudioStream = load("res://assets/sfx/ritual/Control Point Draining 1.mp3")

var cleanse_progress: float = 0:
	set(value):
		cleanse_progress = clamp(value, 0, 100)
		if cleanse_progress == 100:
			cleanse()

func _ready() -> void:
	tree_exited.connect(reset)
	randomize()
	_cleanse_sfx_full = cleanse_sfx.duplicate()
	_cleanse_sfx_full.shuffle()

func _process(_delta):
	cleanse_ui.value = cleanse_progress

func reset():
	SoundManager.stop_sound(ritual_sfx)

func cleanse():
	anim_player.play("cleansing")
	SoundManager.play_sound(ritual_sfx)

func cleanse_complete():
	# TODO - add buffs to crusader/update loss counter/UI
	SoundManager.stop_sound(ritual_sfx)
	GameManager.play_sfx_shuffled(_cleanse_sfx_full, cleanse_sfx)
	
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
