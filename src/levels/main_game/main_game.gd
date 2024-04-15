extends Node2D
class_name MainGame

@export var minion_spawn: Node2D
@export var crusader: Crusader
@export var ritual_sites: Node2D

@export var crt_effect: Control
@export var fog_effect: Control

@onready var main_ui: Control = $CanvasLayer/GameUI
@onready var patrol_path = $Ground/Path2D

var total_ritual_sites: int
var sites_cleansed: int = 0

func _ready() -> void:
	GameManager.main_game = self
	total_ritual_sites = ritual_sites.get_child_count()

	for site in ritual_sites.get_children():
		site.cleansed.connect(_on_ritual_site_cleansed)
	crusader.death.connect(_on_crusader_killed)
	
	crusader.path = patrol_path.curve
	crusader.path_points = patrol_path.curve.get_baked_points()
	
	main_ui.init_health(crusader.current_health)
	crusader.health_changed.connect(main_ui._set_health)
	
	for minion in minion_spawn.get_children():
		minion.crusader = crusader

func _on_ritual_site_cleansed():
	sites_cleansed += 1
	if sites_cleansed == total_ritual_sites:
		GameManager.end_game(false)

func _on_crusader_killed():
	GameManager.end_game(true)
