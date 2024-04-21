extends Control
class_name SpellbookUI

@export var prefix_data: Array[SpellPrefixResource]
@export var spell_data: Array[SpellMainResource]
@export var spellbook_button_prefab: PackedScene

@onready var tab_container: TabContainer = $TabContainer
@onready var grid_container: GridContainer = $TabContainer/Overview/ScrollContainer/GridContainer
@onready var description: RichTextLabel = $TabContainer/Detail/Desc
@onready var spell_image: TextureRect = $TabContainer/Detail/SpellBorder/SpellSprite

func _ready():
    for child in grid_container.get_children():
        child.queue_free()
    create_buttons()
    tab_container.current_tab = 0
    visible = false


func toggle_ui():
    visible = not visible
    tab_container.current_tab = 0

func create_buttons():
    for elem in prefix_data:
        var new_btn = spellbook_button_prefab.instantiate()
        grid_container.add_child(new_btn)
        new_btn.populate_prefix_data(elem)
        new_btn.spellbook_ui = self

    for elem in spell_data:
        var new_btn = spellbook_button_prefab.instantiate()
        grid_container.add_child(new_btn)
        new_btn.populate_spell_data(elem) 
        new_btn.spellbook_ui = self


func load_prefix_detail_view(data: SpellPrefixResource):
    tab_container.current_tab = 1
    description.text = "[center][wave]{0}[/wave][/center]".format([data.name])
    description.text += "\n\n{0}".format([data.spellbook_description])
    spell_image.visible = false

func load_spell_detail_view(data: SpellMainResource):
    tab_container.current_tab = 1
    description.text = "[center][wave]{0}[/wave][/center]".format([data.name])
    description.text += "\n\n{0}".format([data.spellbook_description])
    spell_image.texture = data.spell_sprite
    spell_image.visible = true

func _on_back_button_pressed():
    tab_container.current_tab = 0
