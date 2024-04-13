extends Node

enum SpellMain {
	NONE,
	ZOMBIE,
	MUMMY,
}

enum SpellPrefix {
	NONE,
	SQUARE,
	TRIANGLE,
	AGILE,
	TOUGH
}

func _ready() -> void:
	print(SpellMain.keys()[SpellMain.ZOMBIE])
