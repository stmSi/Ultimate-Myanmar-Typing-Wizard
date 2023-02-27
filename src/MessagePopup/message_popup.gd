extends VBoxContainer

@onready var message_lbl: Label = %MessageLbl
@onready var margin_container: MarginContainer = $MarginContainer
@onready var ok_btn: Button = %OkBtn


func set_msg(msg: String) -> void:
	message_lbl.text = msg
	ok_btn.grab_focus()
	$AnimationPlayer.play('open')

func _on_ok_btn_pressed() -> void:
	EventBus.message_popup_closed.emit()
	$AnimationPlayer.play('close') 
	await $AnimationPlayer.animation_finished
	queue_free()

