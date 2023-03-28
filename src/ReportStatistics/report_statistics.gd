extends PanelContainer
@onready var continue_btn: Button = %ContinueBtn

func _ready() -> void:
	continue_btn.grab_focus()

func _on_continue_btn_pressed() -> void:
	queue_free()
