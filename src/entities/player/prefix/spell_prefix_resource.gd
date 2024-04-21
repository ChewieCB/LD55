extends Resource
class_name SpellPrefixResource

@export var name: String
@export var input: String
@export var prefix_id: EnumAutoload.SpellPrefix
@export var cooldown: float = 0.5
@export_multiline var tooltip_description: String
@export_multiline var spellbook_description: String
