extends Node2D

@onready var damage_theme = load("res://src/ui/themes/damage_label.tres")
@onready var status_theme = load("res://src/ui/themes/status_label.tres")

@onready var status_marker = $StatusMarker
@onready var attack_marker = $AttackMarker
@onready var damage_markers = $DamageMarkers
var damage_markers_in_use = []

func _spawn_status_indicator(
	status: String, duration: float, 
	offset: Vector2 = Vector2.ZERO,
	color: Color = Color.WHITE
):
	var new_indicator = Label.new()
	new_indicator.theme = status_theme
	new_indicator.text = status
	new_indicator.add_theme_color_override("font_color", color)
	new_indicator.z_index = 3
	#
	status_marker.add_child(new_indicator)
	status_marker.position = Vector2(0, -25) + offset
	# Center the label's anchors
	new_indicator.set_anchors_and_offsets_preset(Control.PRESET_CENTER)
	# Set the alignment
	new_indicator.horizontal_alignment = HorizontalAlignment.HORIZONTAL_ALIGNMENT_CENTER
	new_indicator.vertical_alignment = VerticalAlignment.VERTICAL_ALIGNMENT_CENTER
	
	# Animate the damage indicator via tweens to 
	# save us creating a separate anim player
	await get_tree().create_timer(duration).timeout
	var tween = create_tween()
	# TODO - add easing
	tween.tween_property(new_indicator, "modulate", Color(1, 1, 1, 0), 1.0)
	tween.tween_callback(new_indicator.queue_free)


func _spawn_attack_indicator(attack_name: String, duration: float):
	var new_indicator = Label.new()
	new_indicator.theme = status_theme
	new_indicator.text = attack_name
	new_indicator.z_index = 3
	#
	if attack_marker.get_child_count() > 0:
		var old_indicator = attack_marker.get_child(0)
		attack_marker.remove_child(old_indicator)
	
	attack_marker.add_child(new_indicator)
	attack_marker.position = Vector2(0, -50)
	# Center the label's anchors
	new_indicator.set_anchors_and_offsets_preset(Control.PRESET_CENTER)
	# Set the alignment
	new_indicator.horizontal_alignment = HorizontalAlignment.HORIZONTAL_ALIGNMENT_CENTER
	new_indicator.vertical_alignment = VerticalAlignment.VERTICAL_ALIGNMENT_CENTER
	
	# Animate the damage indicator via tweens to 
	# save us creating a separate anim player
	await get_tree().create_timer(duration).timeout
	var tween = create_tween()
	# TODO - add easing
	# Catch for if the parent node is freed
	if tween:
		tween.parallel().chain().tween_property(new_indicator, "modulate", Color(1, 1, 1, 0), 1.0)
		tween.parallel().chain().tween_property(new_indicator, "position:y", new_indicator.position.y - 24, 1.0)
		tween.tween_callback(new_indicator.queue_free)


func _spawn_damage_indicator(damage: int):
	var new_indicator = Label.new()
	new_indicator.theme = damage_theme
	new_indicator.text = str(abs(damage))
	new_indicator.z_index = 3
	
	var damage_marker
	var possible_markers = damage_markers.get_children()
	possible_markers.shuffle()
	for _marker in possible_markers:
		if _marker in damage_markers_in_use:
			continue
		else:
			damage_marker = _marker
			break
	# If we get through all of the available markers, spawn at the oldest one
	if not damage_marker:
		damage_marker = damage_markers_in_use.front()
		
	damage_markers_in_use.append(damage_marker)
	damage_marker.add_child(new_indicator)
	
	# Center the label's anchors
	new_indicator.set_anchors_and_offsets_preset(Control.PRESET_CENTER)
	# Set the alignment
	new_indicator.horizontal_alignment = HorizontalAlignment.HORIZONTAL_ALIGNMENT_CENTER
	new_indicator.vertical_alignment = VerticalAlignment.VERTICAL_ALIGNMENT_CENTER
	
	# Animate the damage indicator via tweens to 
	# save us creating a separate anim player
	var tween = create_tween()
	# TODO - add easing
	tween.tween_property(new_indicator, "position:y", new_indicator.position.y - 24, 1.0)
	tween.tween_property(new_indicator, "modulate", Color(1, 1, 1, 0), 1.0)
	tween.tween_callback(new_indicator.queue_free)
	tween.tween_callback(func():
		damage_markers_in_use.erase(damage_marker)
	)
