extends Node2D
class_name MainGame

@onready var main_ui: Control = $CanvasLayer/GameUI

@onready var patrol_path = $Ground/Path2D
@onready var minion_spawn = $Minions
@onready var crusader = $Crusader

@onready var ritual_sites = $RitualSites
@onready var total_ritual_sites = ritual_sites.get_child_count()
var sites_cleansed: int = 0


func _ready() -> void:
	GameManager.main_game = self
	
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
		# TODO - game over state
		print("Game Over!")
		GameManager.end_game(false)


func _on_crusader_killed():
	# TODO - win state
	print("You Win!")
	GameManager.end_game(true)
