extends Control

@onready var panel: Panel = $Panel
@onready var margin_container: MarginContainer = $Panel/MarginContainer
@onready var follow_up_rich_text: RichTextLabel = $Panel/MarginContainer/FollowUpRichText

var ori_richtext_minimum_size_x: float
var raw_text: String

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	ori_richtext_minimum_size_x = follow_up_rich_text.custom_minimum_size.x
	EventBus.exercise_loaded.connect(self._set_raw_text)
	EventBus.followup_popup_pos_changed.connect(self._on_followup_popup_pos_changed)
	EventBus.written_string_changed.connect(self._on_written_string_changed)
	pass # Replace with function body.

func _set_raw_text(t: String) -> void:
	raw_text = t

func _on_followup_popup_pos_changed(pos: Vector2):
	if visible:
		var tween = get_tree().create_tween()
		tween.tween_property(self, "global_position", pos, .2).set_trans(Tween.TRANS_CUBIC)
#		global_position = pos
	pass

func _on_written_string_changed(s: String):
	var delta_move = ((s.length())  * follow_up_rich_text.get_theme_font_size("normal_font_size")) / 2.5
#	margin_container.position.x = -delta_move
	follow_up_rich_text.custom_minimum_size.x =  (ori_richtext_minimum_size_x + delta_move)
