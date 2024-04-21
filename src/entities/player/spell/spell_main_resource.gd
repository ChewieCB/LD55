extends Resource
class_name SpellMainResource

@export var name: String
@export var input: String
@export var spell_id: EnumAutoload.SpellMain
@export var spawn_scene: PackedScene
@export var spell_sprite: Texture2D
@export var cooldown: float = 0.5
@export_multiline var tooltip_description: String
@export_multiline var spellbook_description: String

