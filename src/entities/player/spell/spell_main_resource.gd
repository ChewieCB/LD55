extends Resource
class_name SpellMainResource

@export var name: String
@export var input: String
@export var spell_id: EnumAutoload.SpellMain
@export var spawn_scene: PackedScene
@export var monster_sprite: Texture2D
@export var cooldown: float = 0.5
@export_multiline var description: String
