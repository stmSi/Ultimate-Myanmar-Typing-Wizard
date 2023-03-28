extends PanelContainer
@onready var continue_btn: Button = %ContinueBtn

signal close

func _ready() -> void:
#	get_tree().paused = true
	continue_btn.grab_focus()

func _on_continue_btn_pressed() -> void:
	queue_free()
	self.close.emit()
#	get_tree().paused = false
