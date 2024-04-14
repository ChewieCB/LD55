extends Resource
class_name AttackResource

@export var attack_range: int = 40
@export var cooldown: float = 1.0
@export var damage: int = 10
@export var armour_penetration: int = 0
# How much the attack slow enemy movement - cause stagger/stun chance
@export_range(0.0, 1.0) var control: float
