extends CharacterBody2D
class_name Troop

@export var move_speed: int = 100
@export var attack_range: int = 40
@export var attack_inverval: float = 1.0
@export var damage: int = 10
@export var max_hp: int = 100

@onready var attack_timer: Timer = $AttackTimer
@onready var attack_label: Label = $AttackLabel

var hero: Hero
var current_hp: int
var is_in_attack = false

func _ready() -> void:
	attack_label.visible = false
	current_hp = max_hp
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
	attack_timer.start(attack_inverval)

func _on_attack_timer_timeout() -> void:
	attack_label.visible = false
	is_in_attack = false

func apply_effect(effect: EnumAutoload.SpellPrefix):
	match effect:
		EnumAutoload.SpellPrefix.AGILE:
			# Increase speed by 40%
			move_speed = int(move_speed * 1.4)
		EnumAutoload.SpellPrefix.TOUGH:
			# Increase max HP and size by 25%
			var current_hp_perc = current_hp / float(max_hp)
			max_hp = int(max_hp * 1.2)
			current_hp = int(current_hp_perc * max_hp)
			scale = scale * 1.2
