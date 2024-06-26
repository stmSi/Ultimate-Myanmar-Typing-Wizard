extends PanelContainer
class_name ReportStatisticsUI
@onready var continue_btn: Button = %ContinueBtn

signal close

func _ready() -> void:
	get_tree().paused = true
	continue_btn.grab_focus()

func _on_continue_btn_pressed() -> void:
	queue_free()
	get_tree().paused = false
	self.close.emit()
