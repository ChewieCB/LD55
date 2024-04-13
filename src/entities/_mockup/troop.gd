extends CharacterBody2D
class_name Troop

@export var move_speed: int = 120
@export var attack_range: int = 40

@onready var attack_timer: Timer = $AttackTimer
@onready var attack_label: Label = $AttackLabel

var hero: Hero
var is_in_attack = false

func _ready() -> void:
	attack_label.visible = false
	await get_tree().physics_frame
	await get_tree().physics_frame
	hero = GameManager.hero

func _physics_process(_delta: float):
	if !hero:
		return
	var target = hero.global_position
	if global_position.distance_to(target) < attack_range:
		attack()
	if is_in_attack:
		velocity = Vector2.ZERO
	else:
		velocity = (target - global_position).normalized() * move_speed
	move_and_slide()

func attack():
	attack_label.visible = true
	is_in_attack = true
	attack_timer.start()

func _on_attack_timer_timeout() -> void:
	attack_label.visible = false
	is_in_attack = false
