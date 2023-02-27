extends Control

@onready var panel: Panel = $Panel


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	EventBus.followup_popup_pos_changed.connect(self._on_followup_popup_pos_changed)
	pass # Replace with function body.

func _on_followup_popup_pos_changed(pos: Vector2):
	if visible:
		global_position = pos
	pass
