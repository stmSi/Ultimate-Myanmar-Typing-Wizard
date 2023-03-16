extends VBoxContainer

@onready var message_lbl: RichTextLabel = %MessageLbl
@onready var margin_container: MarginContainer = $MarginContainer
@onready var ok_btn: Button = %OkBtn


func _ready() -> void:
	add_to_group('msg_popups')
#	get_tree().paused = true


func set_msg(msg: String) -> void:
	%MessageLbl.text = msg
	%OkBtn.grab_focus()
	$AnimationPlayer.play('open')
	await $AnimationPlayer.animation_finished
	$AnimationPlayer.play('running')

func _on_ok_btn_pressed() -> void:
#	if len(get_tree().get_nodes_in_group('msg_popups')) == 1:
#		get_tree().paused = false
	
	EventBus.message_popup_closed.emit()
	$AnimationPlayer.play('close') 
	await $AnimationPlayer.animation_finished
	queue_free()

