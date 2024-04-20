extends Button
class_name SpellbookButton

@onready var monster_image: TextureRect = $MonsterImage
@onready var prefix_text: RichTextLabel = $PrefixText

var spell_data: SpellMainResource
var prefix_data: SpellPrefixResource

func _ready():
	text = ""
	monster_image.texture = null
	prefix_text.text = ""


func populate_spell_data(data: SpellMainResource):
	spell_data = data
	prefix_data = null
	monster_image.texture = data.monster_sprite
	# set("theme_override_colors/font_color", Color.GREEN)
	# text = spell_data.name

func populate_prefix_data(data: SpellPrefixResource):
	spell_data = null
	prefix_data = data
	set("theme_override_colors/font_color", Color.YELLOW)
	text = prefix_data.name
