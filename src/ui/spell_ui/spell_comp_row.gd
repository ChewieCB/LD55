extends Control
class_name SpellCompRow

@onready var name_label: RichTextLabel = $VBoxContainer/Name
@onready var input_label: RichTextLabel = $VBoxContainer/Input
@onready var cooldown_bar: TextureProgressBar = $VBoxContainer/CooldownBar
@onready var timer: Timer = $Timer

var spell_data: SpellMainResource
var prefix_data: SpellPrefixResource

var tween: Tween

func _ready() -> void:
	cooldown_bar.value = 100

func populate_spell_data(data: SpellMainResource):
	spell_data = data
	prefix_data = null
	name_label.text = "[right][wave]{0}[/wave][/right]".format([data.name])
	input_label.text = "[center]-{0}-[/center]".format([Utils.convert_text_to_arrow(data.input, "black")])
	cooldown_bar.fill_mode = TextureProgressBar.FILL_RIGHT_TO_LEFT
	GameManager.player_control.spell_casted.connect(check_cooldown)

func populate_prefix_data(data: SpellPrefixResource):
	spell_data = null
	prefix_data = data
	name_label.text = "[wave]{0}[/wave]".format([data.name])
	input_label.text = "[center]-{0}-[/center]".format([Utils.convert_text_to_arrow(data.input, "black")])
	GameManager.player_control.spell_casted.connect(check_cooldown)

func check_cooldown(prefix_id: EnumAutoload.SpellPrefix, spell_id: EnumAutoload.SpellMain):
	if prefix_id != EnumAutoload.SpellPrefix.NONE and prefix_data != null:
		if prefix_id == prefix_data.prefix_id:
			start_cooldown(prefix_data.cooldown)
	if spell_id != EnumAutoload.SpellMain.NONE and spell_data != null:
		if spell_id == spell_data.spell_id:
			start_cooldown(spell_data.cooldown)

func start_cooldown(duration: float):
	if tween:
		tween.kill()
	tween = get_tree().create_tween()
	cooldown_bar.value = 0
	tween.tween_property(cooldown_bar, "value", 100, duration).set_trans(Tween.TRANS_LINEAR)
	timer.start(duration)
	modulate = Color(1, 1, 1, 0.5)

func _on_timer_timeout() -> void:
	modulate = Color(1, 1, 1, 1)
