extends Node2D
class_name PlayerControl

@export var zombie_prefab: PackedScene
@export var mummy_prefab: PackedScene
@export var crusader: Crusader


var spell_list = ['DDDUUU', 'UUDDLRLR']
var current_spell: String = ""
var is_casting = false
var spell_ready = false
var translated_main_spell: EnumAutoload.SpellMain = EnumAutoload.SpellMain.NONE
var translated_prefix: EnumAutoload.SpellPrefix = EnumAutoload.SpellPrefix.NONE

const MAX_SPELL_LENGTH = 20

func _ready() -> void:
	GameManager.player_control = self
	current_spell = ""

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("start_cast"):
		if not is_casting:
			start_cast()
		else:
			confirm_spell()
	if event.is_action_pressed("cast_readied_spell"):
		cast_readied_spell()

	if not is_casting:
		return
	if event.is_action_pressed("left"):
		cast_input("left")
	if event.is_action_pressed("right"):
		cast_input("right")
	if event.is_action_pressed("up"):
		cast_input("up")
	if event.is_action_pressed("down"):
		cast_input("down")
	if event.is_action_pressed("delete"):
		cast_input("delete")

func start_cast():
	GameManager.game_ui.set_spell_label("Input:")
	current_spell = ""
	is_casting = true
	spell_ready = false
	translated_main_spell = EnumAutoload.SpellMain.NONE
	translated_prefix = EnumAutoload.SpellPrefix.NONE

func confirm_spell():
	var spell_data = parse_spell_input(current_spell)
	var main_spell = spell_data["main_spell"]
	var prefix = spell_data["prefix"]
	is_casting = false
	if main_spell == "":
		GameManager.game_ui.set_spell_label("Failed spell. Press Space to cast again")
	else:
		spell_ready = true
		translated_main_spell = translate_spell_component(main_spell)
		translated_prefix = translate_spell_component(prefix, true)
		if translated_prefix == EnumAutoload.SpellPrefix.NONE:
			GameManager.game_ui.set_spell_label("Ready: {0}".format([convert_enum_to_str(translated_main_spell)]))
		else:
			GameManager.game_ui.set_spell_label("Ready: {0} + {1}".format([
				convert_enum_to_str(translated_prefix, true), convert_enum_to_str(translated_main_spell)]))

func cast_readied_spell():
	if not spell_ready:
		return
	var prefab_to_spawn: PackedScene = null
	# Decide what to spawn
	match translated_main_spell:
		EnumAutoload.SpellMain.ZOMBIE:
			prefab_to_spawn = zombie_prefab
		#EnumAutoload.SpellMain.MUMMY:
			#prefab_to_spawn = mummy_prefab

	if prefab_to_spawn == null:
		print("ERROR prefab_to_spawn is null")
		return

	# Decide how we spawn it
	var mouse_global_pos = get_global_mouse_position()
	if translated_prefix != EnumAutoload.SpellPrefix.NONE:
		match translated_prefix:
			EnumAutoload.SpellPrefix.SQUARE:
				# Will spawn 4 in each corner of square shape
				var spawn_ul: AIAgent = prefab_to_spawn.instantiate()
				spawn_ul.crusader = crusader
				GameManager.main_game.minion_spawn.add_child(spawn_ul)
				spawn_ul.global_position = mouse_global_pos + Vector2( - 20, -20)
				var spawn_ur: AIAgent = prefab_to_spawn.instantiate()
				spawn_ur.crusader = crusader
				GameManager.main_game.minion_spawn.add_child(spawn_ur)
				spawn_ur.global_position = mouse_global_pos + Vector2(20, -20)
				var spawn_ll: AIAgent = prefab_to_spawn.instantiate()
				spawn_ll.crusader = crusader
				GameManager.main_game.minion_spawn.add_child(spawn_ll)
				spawn_ll.global_position = mouse_global_pos + Vector2( - 20, 20)
				var spawn_lr: AIAgent = prefab_to_spawn.instantiate()
				spawn_lr.crusader = crusader
				GameManager.main_game.minion_spawn.add_child(spawn_lr)
				spawn_lr.global_position = mouse_global_pos + Vector2(20, 20)
			EnumAutoload.SpellPrefix.TRIANGLE:
				# Will spawn 3 in each corner of triangle shape
				var spawn_top: AIAgent = prefab_to_spawn.instantiate()
				spawn_top.crusader = crusader
				GameManager.main_game.minion_spawn.add_child(spawn_top)
				spawn_top.global_position = mouse_global_pos + Vector2(0, -10)
				var spawn_left: AIAgent = prefab_to_spawn.instantiate()
				spawn_left.crusader = crusader
				GameManager.main_game.minion_spawn.add_child(spawn_left)
				spawn_left.global_position = mouse_global_pos + Vector2( - 20, 10)
				var spawn_right: AIAgent = prefab_to_spawn.instantiate()
				spawn_right.crusader = crusader
				GameManager.main_game.minion_spawn.add_child(spawn_right)
				spawn_right.global_position = mouse_global_pos + Vector2(20, 10)
			EnumAutoload.SpellPrefix.AGILE, EnumAutoload.SpellPrefix.TOUGH:
				var spawn_single: AIAgent = prefab_to_spawn.instantiate()
				spawn_single.crusader = crusader
				GameManager.main_game.minion_spawn.add_child(spawn_single)
				spawn_single.global_position = mouse_global_pos
				apply_effect(spawn_single, translated_prefix)

	else:
		var spawn_single: AIAgent = prefab_to_spawn.instantiate()
		spawn_single.crusader = crusader
		GameManager.main_game.minion_spawn.add_child(spawn_single)
		spawn_single.global_position = mouse_global_pos
	finish_cast()

func finish_cast():
	GameManager.game_ui.set_spell_label("Press Space to start")
	current_spell = ""
	is_casting = false
	spell_ready = false
	translated_main_spell = EnumAutoload.SpellMain.NONE
	translated_prefix = EnumAutoload.SpellPrefix.NONE


func apply_effect(minion: AIAgent, effect: EnumAutoload.SpellPrefix):
	match effect:
		EnumAutoload.SpellPrefix.AGILE:
			# Increase speed by 40%
			minion.speed = int(minion.speed * 1.4)
		#EnumAutoload.SpellPrefix.TOUGH:
			## Increase max HP and size by 25%
			#var current_hp_perc = current_hp / float(max_hp)
			#max_hp = int(max_hp * 1.2)
			#current_hp = int(current_hp_perc * max_hp)
			#scale = scale * 1.2

func translate_spell_component(input: String, is_prefix=false):
	if is_prefix:
		match input:
			"UUU":
				return EnumAutoload.SpellPrefix.SQUARE
			"LLL":
				return EnumAutoload.SpellPrefix.TRIANGLE
			"UULLRR":
				return EnumAutoload.SpellPrefix.AGILE
			"UUUDDDUD":
				return EnumAutoload.SpellPrefix.TOUGH
			_:
				return EnumAutoload.SpellPrefix.NONE
	else:
		match input:
			"DDDUUU":
				return EnumAutoload.SpellMain.ZOMBIE
			"UUDDLRLR":
				return EnumAutoload.SpellMain.MUMMY
			_:
				return EnumAutoload.SpellMain.NONE

func convert_enum_to_str(content: int, is_prefix=false):
	if is_prefix:
		return EnumAutoload.SpellPrefix.keys()[content]
	else:
		return EnumAutoload.SpellMain.keys()[content]

func cast_input(input: String):
	if len(current_spell) >= MAX_SPELL_LENGTH:
		return

	match input:
		"up":
			current_spell += "U"
		"down":
			current_spell += "D"
		"left":
			current_spell += "L"
		"right":
			current_spell += "R"
		"delete":
			if len(current_spell) > 0:
				current_spell = current_spell.substr(0, len(current_spell) - 1)
	GameManager.game_ui.set_spell_label("Input: " + current_spell)

func parse_spell_input(input_string: String):
	var min_spell_len = 9999
	var max_spell_len = 0
	for spell in spell_list:
		if len(spell) < min_spell_len:
			min_spell_len = len(spell)
		if len(spell) > max_spell_len:
			max_spell_len = len(spell)

	var found_spell = ""
	var prefix = ""

	for i in range(len(input_string)):
		for length in range(min_spell_len, max_spell_len + 1):
			if i + length <= len(input_string):
				if input_string.substr(i, length) in spell_list:
					found_spell = input_string.substr(i, length)
					prefix = input_string.substr(0, i)
					break
		if found_spell != "":
			break

	if found_spell == "":
		#TODO
		print("Cant find spell")

	return {"prefix": prefix, "main_spell": found_spell}
