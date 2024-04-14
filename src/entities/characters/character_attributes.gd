extends Resource
class_name CharacterAttributes

enum Rank {
	NONE,
	HORDE,
	ELITE,
	TANK
}

@export var health: int
@export var armour: int  # Reduced damage taken, ignored by armour-piercing attacks
@export var speed: int  # Movement speed of agent
@export_range(0.0, 1.0) var dexterity: float  # Affects attack speed, how much agent is slowed by attacks
@export var rank: Rank
