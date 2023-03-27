extends Node

@onready var message_popup = preload("res://src/MessagePopup/message_popup.tscn")


func _ready() -> void:
	EventBus.message_popup.connect(
		func(msg: String, ok_func = null): call_deferred("_on_message_popup", msg, ok_func)
	)
	pass


func _on_message_popup(msg: String, ok_func = null):
	var popup_groups = _get_popups_group()
	var message_popup_instance: Control = message_popup.instantiate()

#	# slightly move up base on number of messages popup
#	message_popup_instance.position -= Vector2(
#		200 + popup_groups.get_child_count(),
#		200 + popup_groups.get_child_count()
#	)
	popup_groups.add_child(message_popup_instance)

	if ok_func:
		var ok_btn: Button = message_popup_instance.get_node(
			"./MarginContainer/MarginContainer/VBoxContainer/OkBtn"
		)
		ok_btn.pressed.connect(func(): ok_func.call())
	# first come, first serve
#	popup_groups.move_child(message_popup_instance, 0)

	message_popup_instance.call_deferred("set_msg", msg)

	pass


func _get_popups_group() -> Control:
	var loaded_scene = get_tree().root.get_child(get_tree().root.get_child_count() - 1)
	if loaded_scene.has_node("PopupsGroup"):
		return loaded_scene.get_node("PopupsGroup")

	var popup_groups = Control.new()
	popup_groups.name = "PopupsGroup"

	popup_groups.global_position = get_viewport().get_visible_rect().size / 2
	loaded_scene.add_child(popup_groups)
	return popup_groups
