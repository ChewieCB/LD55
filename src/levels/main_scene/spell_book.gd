extends Control

@export var prefix_data: Array[SpellPrefixResource]
@export var spell_data: Array[SpellMainResource]
@export var spellbook_button_prefab: PackedScene

@onready var grid_container: GridContainer = $TabContainer/Overview/ScrollContainer/GridContainer

func _ready():
    for child in grid_container.get_children():
        child.queue_free()
    create_buttons()

func create_buttons():
    for elem in prefix_data:
        var new_btn = spellbook_button_prefab.instantiate()
        grid_container.add_child(new_btn)
        new_btn.populate_prefix_data(elem)

    for elem in spell_data:
        var new_btn = spellbook_button_prefab.instantiate()
        grid_container.add_child(new_btn)
        new_btn.populate_spell_data(elem) 
