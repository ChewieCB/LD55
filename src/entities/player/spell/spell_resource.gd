extends Resource
class_name SpellResource

@export var name: String
@export var input: String
@export var is_prefix: bool

@export_group("Main")
@export var spell_id: EnumAutoload.SpellMain
@export var minion: PackedScene

@export_group("Prefix")
@export var prefix_id: EnumAutoload.SpellPrefix