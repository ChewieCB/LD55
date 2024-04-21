extends Button
class_name SpellbookButton

@onready var monster_image: TextureRect = $MonsterImage

var spell_data: SpellMainResource
var prefix_data: SpellPrefixResource
var spellbook_ui: SpellbookUI

func _ready():
	text = ""
	monster_image.texture = null


func populate_spell_data(data: SpellMainResource):
	spell_data = data
	prefix_data = null
	monster_image.texture = data.spell_sprite

func populate_prefix_data(data: SpellPrefixResource):
	spell_data = null
	prefix_data = data
	text = prefix_data.name

func _on_mouse_entered():
	Utils.play_button_hover_sfx()

func _on_pressed():
	if spell_data != null:
		spellbook_ui.load_spell_detail_view(spell_data)
	else:
		spellbook_ui.load_prefix_detail_view(prefix_data)
	Utils.play_button_click_sfx()
