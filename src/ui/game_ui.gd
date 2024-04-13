extends Control
class_name GameUI

@onready var spell_label: Label = $SpellPanel/Label
@onready var time_panel: Label = $TimePanel/Label

var spell_list = ['DDDUUU', 'UUDDLRLR']
var current_spell: String = ""
var is_casting = false

const MAX_SPELL_LENGTH = 20

func _ready() -> void:
	GameManager.game_ui = self
	spell_label.text = "Press Space to start"
	current_spell = ""

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("start_cast"):
		if not is_casting:
			start_cast()
		else:
			confirm_spell()

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
	spell_label.text = "Input: "
	current_spell = ""
	is_casting = true

func confirm_spell():
	var spell_data = parse_spell_input(current_spell)
	var prefix = spell_data["prefix"]
	var main_spell = spell_data["main_spell"]
	is_casting = false
	if main_spell == "":
		spell_label.text = "Failed spell. Press Space to cast again"
	else:
		if translate_spell_component(prefix, true) == "":
			spell_label.text = "Ready: {0}".format([translate_spell_component(main_spell)])
		else:
			spell_label.text = "Ready: {0} + {1}".format(
				[translate_spell_component(prefix, true), translate_spell_component(main_spell)])

func translate_spell_component(input: String, is_prefix=false):
	if is_prefix:
		match input:
			"UUU":
				return "Square"
			"LLL":
				return "Triangle"
			"UULLRR":
				return "Agile"
			"UUUDDDUD":
				return "Tough"
	else:
		match input:
			"DDDUUU":
				return "Zombie"
			"UUDDLRLR":
				return "Mummy"
	return ""

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
		"right":
			current_spell += "R"
		"delete":
			if len(current_spell) > 0:
				current_spell = current_spell.substr(0, len(current_spell) - 1)
	spell_label.text = "Input: " + current_spell

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