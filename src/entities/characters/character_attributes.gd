extends Resource
class_name CharacterAttributes

enum Rank {
	HORDE,
	ELITE,
	TANK
}

@export var health: int
@export var armour: int
@export var speed: int
@export var dexterity: int
@export var control: int
@export var rank: Rank
