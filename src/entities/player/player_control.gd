extends Node2D
class_name PlayerControl

signal spell_casted(prefix_id, spell_id)

@export var spells: Array[SpellMainResource]
@export var spell_prefixes: Array[SpellPrefixResource]
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
#
var prefix_dict = {} # map input to SpellPrefixResource
var current_spell: SpellMainResource
var current_spell_str: String = ""
var current_prefix_str: String = ""
var spell_used_timestamp = {}
var prefix_used_timestamp = {}

var raw_input: String = "":
	set(value):
		if len(value) < len(raw_input):
			# Mean we just deleted a character. Reset spell.
			current_spell_str = ""
			if current_prefix_str and len(value) < len(current_prefix_str):
				# We deleted part of prefix, so reset it.
				current_prefix_str = ""
		raw_input = value
		var post_prefix = raw_input
		# FIXME - current_prefix_str stays in input if you start deleting the prefix
		if current_prefix_str:
			if raw_input != current_prefix_str and raw_input in prefix_dict:
				current_prefix_str = raw_input
				return
			post_prefix = raw_input.trim_prefix(current_prefix_str)
		elif raw_input in prefix_dict:
			current_prefix_str = raw_input
			return

		for spell in spells:
			if post_prefix == spell.input:
				current_spell_str = post_prefix
				current_spell = spell
				return
		# If we don't match the string remove the current_spell to prevent
		# overspill being accepted
		current_spell_str = ""
		current_spell = null
var input_arrow_repr: String = "":
	set(value):
		if value == input_arrow_repr:
			return
		input_arrow_repr = value
		play_spell_input_sfx()
		GameManager.game_ui.spell_ui.set_spell_label("Input: %s" % input_arrow_repr)
		GameManager.game_ui.spell_ui.set_mouse_indicator(input_arrow_repr)

var is_casting = false
var spell_ready = false

const MAX_SPELL_LENGTH = 20
const CASTABLE_INPUTS = ["up", "down", "left", "right", "delete"]

func _ready() -> void:
	GameManager.player_control = self
	for prefix in spell_prefixes:
		prefix_dict[prefix.input] = prefix
		prefix_used_timestamp[prefix.prefix_id] = (Time.get_ticks_msec() / 1000.0) - 1000
	for spell in spells:
		spell_used_timestamp[spell.spell_id] = (Time.get_ticks_msec() / 1000.0) - 1000

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("confirm_spell"):
		confirm_spell()
	if event.is_action_pressed("cast_readied_spell"):
		cast_readied_spell()

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

func _process(_delta):
	if is_casting:
		# FIXME - why are we running this every frame? 
		# Would be more sensible to run every time the relevant strings are updated
		if current_prefix_str and current_spell:
			input_arrow_repr = "{0} {1}".format([Utils.convert_text_to_arrow(current_prefix_str, "yellow"), Utils.convert_text_to_arrow(current_spell_str, "green")])
		elif current_prefix_str:
			var trimmed_input = raw_input.trim_prefix(current_prefix_str)
			input_arrow_repr = "{0} {1}".format([Utils.convert_text_to_arrow(current_prefix_str, "yellow"), Utils.convert_text_to_arrow(trimmed_input)])
		elif current_spell:
			input_arrow_repr = Utils.convert_text_to_arrow(current_spell_str, "green")
		else:
			input_arrow_repr = Utils.convert_text_to_arrow(raw_input)

func start_cast():
	GameManager.game_ui.spell_ui.set_spell_label("Input:")
	is_casting = true
	spell_ready = false

func confirm_spell():
	play_confirm_spell_sfx()
	is_casting = false
	if not current_spell:
		GameManager.game_ui.spell_ui.set_spell_label("[color=red]Failed spell![/color]")
		GameManager.game_ui.spell_ui.set_mouse_indicator("")
		# Clear the inputs
		raw_input = ""
		current_spell_str = ""
		current_prefix_str = ""
	else:
		# Check cooldown
		var current_time = Time.get_ticks_msec() / 1000.0
		var spell_is_on_cd = false
		var prefix_is_on_cd = false
		if current_time - spell_used_timestamp[current_spell.spell_id] < current_spell.cooldown:
			spell_is_on_cd = true
		if current_prefix_str:
			var prefix_data: SpellPrefixResource = prefix_dict[current_prefix_str]
			if current_time - prefix_used_timestamp[prefix_data.prefix_id] < prefix_data.cooldown:
				prefix_is_on_cd = true
		if spell_is_on_cd or prefix_is_on_cd:
			GameManager.game_ui.spell_ui.set_spell_label("[color=red]Spell is on cooldown![/color]")
			GameManager.game_ui.spell_ui.set_mouse_indicator("[color=red]On cooldown![/color]")
			# Clear the inputs
			raw_input = ""
			current_spell_str = ""
			current_prefix_str = ""
			return

		# All good, ready the spell
		spell_ready = true
		var ready_str = "Ready: "
		if current_prefix_str:
			ready_str += "[color=yellow](%s) [/color]" % [prefix_dict[current_prefix_str].name]
		ready_str += "[color=green]%s[/color]" % [current_spell.name]
		GameManager.game_ui.spell_ui.set_spell_label(ready_str)
		GameManager.game_ui.spell_ui.set_mouse_indicator(ready_str.trim_prefix("Ready: "))

func cast_readied_spell():
	if not spell_ready:
		return

	# Decide how we spawn it
	var spawn_position = get_global_mouse_position()
	# Lock spawning to within the navigation map
	var nav_maps = NavigationServer2D.get_maps()
	spawn_position = NavigationServer2D.map_get_closest_point(nav_maps[0], spawn_position)
	
	var prefix_id = EnumAutoload.SpellPrefix.NONE
	if current_prefix_str:
		prefix_id = prefix_dict[current_prefix_str].prefix_id
		match prefix_id:
			EnumAutoload.SpellPrefix.SQUARE:
				# Will spawn 4 in each corner of square shape
				for i in range(4):
					var _minion = current_spell.spawn_scene.instantiate()
					_minion.global_position = spawn_position + Vector2( - 20, -20).rotated(PI / 2 * i)
					_minion.crusader = crusader
					GameManager.spawn_minion(_minion)
			EnumAutoload.SpellPrefix.TRIANGLE:
				for i in range(3):
					var _minion = current_spell.spawn_scene.instantiate()
					_minion.global_position = spawn_position + Vector2( - 20, -20).rotated(PI / 2 * i)
					_minion.crusader = crusader
					GameManager.spawn_minion(_minion)
			EnumAutoload.SpellPrefix.AGILE, EnumAutoload.SpellPrefix.TOUGH:
				var _minion = current_spell.spawn_scene.instantiate()
				_minion.global_position = spawn_position
				_minion.crusader = crusader
				_minion.apply_prefix(prefix_id)
				GameManager.spawn_minion(_minion)
	else:
		var _minion = current_spell.spawn_scene.instantiate()
		_minion.global_position = spawn_position
		_minion.crusader = crusader
		GameManager.spawn_minion(_minion)

	SoundManager.play_sound(summon_sfx[randi_range(0, summon_sfx.size() - 1)])
	emit_signal("spell_casted", prefix_id, current_spell.spell_id)
	spell_used_timestamp[current_spell.spell_id] = Time.get_ticks_msec() / 1000.0
	if prefix_id != EnumAutoload.SpellPrefix.NONE:
		prefix_used_timestamp[prefix_id] = Time.get_ticks_msec() / 1000.0

	finish_cast()

func finish_cast():
	GameManager.game_ui.spell_ui.set_spell_label("Use WASD to start casting")
	GameManager.game_ui.spell_ui.set_mouse_indicator("")
	current_spell = null
	is_casting = false
	spell_ready = false

	# Clear the inputs
	raw_input = ""
	current_spell_str = ""
	current_prefix_str = ""

func cast_input(input: String):
	if not is_casting:
		start_cast()

	if len(raw_input) >= MAX_SPELL_LENGTH:
		return

	if input not in CASTABLE_INPUTS:
		return

	if input == "delete":
		if len(raw_input) > 0:
			raw_input = raw_input.substr(0, len(raw_input) - 1)
	else:
		raw_input += input[0].to_upper()

	# FIXME - emit a signal using the current_spell signal
	# GameManager.game_ui.spell_ui.set_spell_label("Input: " + Utils.convert_text_to_arrow(raw_input))
	SoundManager.play_sound(input_sfx[randi_range(0, input_sfx.size() - 1)])

func play_spell_input_sfx():
	# TODO: Replace with better sfx
	Utils.play_button_hover_sfx()

func play_confirm_spell_sfx():
	# TODO: Replace with better sfx
	Utils.play_button_click_sfx()
