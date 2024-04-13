extends Node2D
class_name PlayerControl

@export var minions: Array[MinionResource]
# TODO - replace this with a SpellModifier resource
var prefixes = {
	"UUU": "Square",
	"LLL": "Triangle",
	"UULLRR": "Agile",
	"UUUDDDUD": "Tough"
}
@export var crusader: Crusader

@onready var _summon_sfx_1 = load("res://assets/sfx/summoning/Summoning_noise_1.mp3")
@onready var _summon_sfx_2 = load("res://assets/sfx/summoning/Summoning_noise_2.mp3")
@onready var _summon_sfx_3 = load("res://assets/sfx/summoning/Summoning_noise_3.mp3")
@onready var _summon_sfx_4 = load("res://assets/sfx/summoning/Summoning_noise_4.mp3")
@onready var summon_sfx = [_summon_sfx_1, _summon_sfx_2, _summon_sfx_3, _summon_sfx_4]
#
@onready var _input_sfx_1 = load("res://assets/sfx/Knock_Reverb.mp3")
@onready var _input_sfx_2 = load("res://assets/sfx/Knock_Reverb_2.mp3")
@onready var _input_sfx_3 = load("res://assets/sfx/Knock_Reverb_3.mp3")
@onready var _input_sfx_4 = load("res://assets/sfx/Knock_Reverb_4.mp3")
@onready var _input_sfx_5 = load("res://assets/sfx/Knock_Reverb_5.mp3")
@onready var _input_sfx_6 = load("res://assets/sfx/Knock_Reverb_6.mp3")
@onready var input_sfx = [_input_sfx_1, _input_sfx_2, _input_sfx_3, _input_sfx_4, _input_sfx_5, _input_sfx_6]


var spell_input: String = "":
	set(value):
		spell_input = value
		var post_prefix = spell_input
		if current_prefix:
			if spell_input != current_prefix and spell_input in prefixes:
				current_prefix = spell_input
				return
			post_prefix = spell_input.trim_prefix(current_prefix)
		elif spell_input in prefixes:
			current_prefix = spell_input
			return
		
		for minion in minions:
			if post_prefix == minion.spell_input:
				current_spell_str = post_prefix
				current_spell = minion
				return 
		# If we don't match the string remove the current_spell to prevent
		# overspill being accepted
		current_spell_str = ""
		current_spell = null
var spell_input_repr: String = "":
	set(value):
		spell_input_repr = value
		GameManager.game_ui.set_spell_label("Input: %s" % spell_input_repr)

var current_spell_str: String = ""
var current_spell: MinionResource
var current_prefix: String = ""

var is_casting = false
var spell_ready = false

const MAX_SPELL_LENGTH = 20
const CASTABLE_INPUTS = ["up", "down", "left", "right", "delete"]


func _ready() -> void:
	GameManager.player_control = self


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
	
	var action
	if event.is_action_pressed("up"):
		action = "up"
	elif event.is_action_pressed("down"):
		action = "down"
	elif event.is_action_pressed("left"):
		action = "left"
	elif event.is_action_pressed("right"):
		action = "right"
	elif event.is_action_pressed("delete"):
		action = "delete"
	
	if action:
		cast_input(action)


func _process(delta):
	if is_casting:
		if current_prefix and current_spell:
			spell_input_repr = "[color=yellow]%s[/color] [color=green]%s[/color]" % [current_prefix, current_spell_str]
		elif current_prefix:
			spell_input_repr = "[color=yellow]%s[/color] %s" % [
				current_prefix,
				spell_input.trim_prefix(current_prefix)
			]
		elif current_spell:
			spell_input_repr = "[color=green]%s[/color]" % [current_spell_str]
		else:
			spell_input_repr = "%s" % [spell_input]


func start_cast():
	GameManager.game_ui.set_spell_label("Input:")
	is_casting = true
	spell_ready = false


func confirm_spell():
	is_casting = false
	
	if not current_spell:
		GameManager.game_ui.set_spell_label("Failed spell. Press Space to cast again")
		# Clear the inputs
		spell_input = ""
		current_spell_str = ""
		current_prefix = ""
	else:
		spell_ready = true
		var ready_str = "Ready: "
		if current_prefix:
			ready_str += "[color=yellow](%s) [/color]" % [prefixes[current_prefix]]
		ready_str += "[color=green]%s[/color]" % [current_spell.name]
		GameManager.game_ui.set_spell_label(ready_str)


func cast_readied_spell():
	if not spell_ready:
		return

	# Decide how we spawn it
	var mouse_global_pos = get_global_mouse_position()
	if current_prefix:
		var prefix_value = prefixes[current_prefix]
		match prefix_value:
			"Square":
				# Will spawn 4 in each corner of square shape
				for i in range(4):
					var _minion = current_spell.scene.instantiate()
					_minion.global_position = mouse_global_pos + Vector2(-20, -20).rotated(PI/2 * i)
					_minion.crusader = crusader
					GameManager.main_game.minion_spawn.add_child(_minion)
			"Triangle":
				for i in range(3):
					var _minion = current_spell.scene.instantiate()
					_minion.global_position = mouse_global_pos + Vector2(-20, -20).rotated(PI/2 * i)
					_minion.crusader = crusader
					GameManager.main_game.minion_spawn.add_child(_minion)
			"Agile":
				# Increase speed by 40%
				var _minion = current_spell.scene.instantiate()
				_minion.global_position = mouse_global_pos
				_minion.speed *= 1.4
				_minion.scale *= 0.7
				_minion.crusader = crusader
				GameManager.main_game.minion_spawn.add_child(_minion)
			"Tough":
				# Double health
				var _minion = current_spell.scene.instantiate()
				_minion.global_position = mouse_global_pos
				_minion.attributes.health *= 2
				_minion.current_health = _minion.attributes.health
				_minion.scale *= 1.4
				_minion.crusader = crusader
				GameManager.main_game.minion_spawn.add_child(_minion)
	else:
		var _minion = current_spell.scene.instantiate()
		_minion.global_position = mouse_global_pos
		_minion.crusader = crusader
		GameManager.main_game.minion_spawn.add_child(_minion)
	
	SoundManager.play_sound(summon_sfx[randi_range(0, summon_sfx.size() - 1)])
	
	finish_cast()


func finish_cast():
	GameManager.game_ui.set_spell_label("Press Space to start")
	current_spell = null
	is_casting = false
	spell_ready = false
	
	# Clear the inputs
	spell_input = ""
	current_spell_str = ""
	current_prefix = ""


func cast_input(input: String):
	if len(spell_input) >= MAX_SPELL_LENGTH:
		return
	
	if input not in CASTABLE_INPUTS:
		return
	
	if input == "delete":
		if len(spell_input) > 0:
			spell_input = spell_input.substr(0, len(spell_input) - 1)
	else:
		spell_input += input[0].to_upper()
	
	# FIXME - emit a signal using the current_spell signal
	GameManager.game_ui.set_spell_label("Input: " + spell_input)
	SoundManager.play_sound(input_sfx[randi_range(0, input_sfx.size() - 1)])
