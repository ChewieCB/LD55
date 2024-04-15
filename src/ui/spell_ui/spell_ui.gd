extends Control
class_name SpellUI

@export var spell_comp_row_prefab: PackedScene

@onready var spell_label: RichTextLabel = $SpellPanel/Label
@onready var mouse_spell_indicator: RichTextLabel = $MouseSpellIndicator
@onready var prefix_container = $BackgroundArt/LeftScroll/PrefixContainer
@onready var spell_container = $BackgroundArt/RightScroll/SpellContainer

func _ready() -> void:
	set_spell_label("Use WASD to start casting")
	await get_tree().process_frame
	await get_tree().process_frame
	generate_spell_comp_row()

func _process(_delta: float) -> void:
	mouse_spell_indicator.global_position = get_global_mouse_position() + Vector2( - mouse_spell_indicator.size.x / 2, 10)

func generate_spell_comp_row():
	for child in prefix_container.get_children():
		child.queue_free()
	for child in spell_container.get_children():
		child.queue_free()

	for prefix in GameManager.player_control.spell_prefixes:
		var new_row: SpellCompRow = spell_comp_row_prefab.instantiate()
		prefix_container.add_child(new_row)
		new_row.populate_prefix_data(prefix)

	for spell in GameManager.player_control.spells:
		var new_row: SpellCompRow = spell_comp_row_prefab.instantiate()
		spell_container.add_child(new_row)
		new_row.populate_spell_data(spell)

func set_spell_label(text: String):
	spell_label.text = "[center][shake]" + text + "[/shake][/center]"

func set_mouse_indicator(text: String):
	# Change arrow size from 30 to smaller
	text = text.replace("30", "20")
	mouse_spell_indicator.text = "[center][shake]" + text + "[/shake][/center]"
