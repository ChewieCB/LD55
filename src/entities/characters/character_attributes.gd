extends Resource
class_name CharacterAttributes

enum Rank {
	NONE,
	HORDE,
	ELITE,
	TANK
}

@export_category("Display")
@export var summon_sfx: Array[AudioStream]

@export var health: int
@export var armour: int # Reduced damage taken, ignored by armour-piercing attacks
@export var speed: float # Movement speed of agent
@export_range(0.0, 1.0) var dexterity: float = 0.5 # Affects attack speed, how much agent is slowed by attacks
@export var rank: Rank


func play_summon_sfx():
	# TODO - make these non-sequential
	if summon_sfx:
		SoundManager.play_sound(summon_sfx[randi_range(0, summon_sfx.size() - 1)])
