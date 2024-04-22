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

@export var walk_sfx: Array[AudioStream]
var _walk_sfx_full = []
@export var death_sfx: Array[AudioStream]
var _death_sfx_full = []

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
	GameManager.play_sfx_shuffled(_summon_sfx_full, summon_sfx)


func play_walk_sfx():
	GameManager.play_sfx_shuffled(_walk_sfx_full, walk_sfx)


func play_death_sfx():
	GameManager.play_sfx_shuffled(_death_sfx_full, death_sfx)
