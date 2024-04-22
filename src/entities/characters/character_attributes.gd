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
var _summon_sfx_full = []

@export var health: int
@export var armour: int # Reduced damage taken, ignored by armour-piercing attacks
@export var speed: float # Movement speed of agent
# Scales damage of attacks
@export var strength: float = 1.0
# Affects attack speed, how much agent is slowed by attacks
@export_range(0.0, 1.0) var dexterity: float = 0.5
@export var rank: Rank

func _ready():
	randomize()
	_summon_sfx_full = summon_sfx.duplicate()
	_summon_sfx_full.shuffle()


func play_summon_sfx():
	if _summon_sfx_full.is_empty():
		_summon_sfx_full = summon_sfx.duplicate()
		_summon_sfx_full.shuffle()
	SoundManager.play_sound(_summon_sfx_full.pop_front())
