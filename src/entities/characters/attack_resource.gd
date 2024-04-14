extends Resource
class_name AttackResource

enum TargetingMode {
	SINGLE,
	MULTIPLE,
	AREA,
}

@export_category("Targeting")
@export var targeting_mode: TargetingMode = TargetingMode.SINGLE
@export var max_targets: int = 1

@export_category("Stats")
@export var attack_range: int = 40
@export var attack_delay: float = 0.0 
@export var cooldown: float = 1.0
@export var damage: int = 10
@export var armour_penetration: int = 0
# How much the attack slow enemy movement - cause stagger/stun chance
@export_range(0.0, 1.0) var control: float

@export_category("Display")
@export var attack_particles_process_mat: ParticleProcessMaterial
@export var attack_particles_canvas_mat: CanvasItemMaterial
@export var attack_sfx: Array[AudioStream]
@export var block_sfx: Array[AudioStream]


func get_targets(attacker: AIAgent):
	# Get target
	var bodies_in_range = attacker.attack_range_area.get_overlapping_bodies()
	bodies_in_range.filter(func(x): return x.current_health > 0)
	bodies_in_range.sort_custom(
		func(a, b):
			if a.global_position.distance_to(attacker.global_position) < b.global_position.distance_to(attacker.global_position):
				return true
			return false
	)
	
	if not bodies_in_range:
		return
	
	var target: AIAgent
	match targeting_mode:
		TargetingMode.SINGLE:
			return [bodies_in_range.front()]
		TargetingMode.MULTIPLE:
			return bodies_in_range.slice(0, max_targets)
		TargetingMode.AREA:
			return bodies_in_range
	
	return null


func play_attack_sfx():
	# TODO - make these non-sequential
	if attack_sfx:
		SoundManager.play_sound(attack_sfx[randi_range(0, attack_sfx.size() - 1)])


func play_block_sfx():
	# TODO - make these non-sequential
	if block_sfx:
		SoundManager.play_sound(block_sfx[randi_range(0, block_sfx.size() - 1)])

