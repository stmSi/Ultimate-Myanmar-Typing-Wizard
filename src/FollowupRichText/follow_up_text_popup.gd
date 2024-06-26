extends Control
class_name FollowUpTextPopup

@onready var panel: Panel = $Panel
@onready var margin_container: MarginContainer = $Panel/MarginContainer
@onready var follow_up_rich_text: RichTextLabel = $Panel/MarginContainer/FollowUpRichText

var ori_richtext_minimum_size_x: float
var raw_text: String

var pending_node: KeyButton = null


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	ori_richtext_minimum_size_x = follow_up_rich_text.custom_minimum_size.x
	EventBus.exercise_loaded.connect(self._set_raw_text)
	EventBus.followup_popup_pos_changed.connect(self._on_followup_popup_pos_changed)
	EventBus.written_string_changed.connect(self._on_written_string_changed)

	GeneralSettings.popup_helper_disabled_changed.connect(
		func(disabled: bool) -> void: visible = not disabled
	)
	visible = not GeneralSettings.get_popup_helper_disabled()


func _set_raw_text(t: String, _idx: int, _e: PackedStringArray) -> void:
	raw_text = t


func _on_followup_popup_pos_changed(_pos: Vector2, node: KeyButton) -> void:
	self.pending_node = node
	call_deferred("_animate_position")  # Hack for first time position not working


# Hack for first time position not working
func _animate_position() -> void:
	var pos := pending_node.global_position

	# left boundry
	if pending_node.global_position.x - (panel.size.x / 2) < 5:  # 5 is for some padding
		pos.x = panel.size.x / 2

	# right
	if pending_node.global_position.x + (panel.size.x / 2) > get_viewport_rect().size.x:  # 5 is for some padding
		pos.x = get_viewport_rect().size.x - (panel.size.x / 2)

	var tween := get_tree().create_tween()
	tween.tween_property(self, "global_position", pos, .2).set_trans(Tween.TRANS_CUBIC)


func _on_written_string_changed(s: String) -> void:
	var delta_move := (
		((s.length()) * follow_up_rich_text.get_theme_font_size("normal_font_size")) / 2.0
	)
#	margin_container.position.x = -delta_move
	follow_up_rich_text.custom_minimum_size.x = (ori_richtext_minimum_size_x + delta_move)
