extends Button
class_name SpellbookButton

@onready var monster_image: TextureRect = $TextureRect

var spell_data: SpellMainResource
var prefix_data: SpellPrefixResource

func populate_spell_data(data: SpellMainResource):
	spell_data = data
	prefix_data = null
	set("theme_override_colors/font_color", Color.GREEN)
	text = spell_data.name

func populate_prefix_data(data: SpellPrefixResource):
	spell_data = null
	prefix_data = data
	set("theme_override_colors/font_color", Color.YELLOW)
	text = prefix_data.name
