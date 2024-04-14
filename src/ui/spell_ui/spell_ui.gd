extends Control
class_name SpellUI

@export var spell_comp_row_prefab: PackedScene

@onready var spell_label: RichTextLabel = $SpellPanel/Label
@onready var prefix_container = $PrefixContainer
@onready var spell_container = $SpellContainer

func _ready() -> void:
	set_spell_label("Press Space to start")
	await get_tree().process_frame
	await get_tree().process_frame
	generate_spell_comp_row()

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