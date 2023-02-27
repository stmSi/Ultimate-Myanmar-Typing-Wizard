extends Node

@onready var message_popup = preload("res://src/MessagePopup/message_popup.tscn")

func _ready() -> void:
	EventBus.message_popup.connect(self._on_message_popup)

func _on_message_popup(msg: String):
	var popup_groups = _get_popups_group()
	var message_popup_instance: Control = message_popup.instantiate()
	
	
#	# slightly move up base on number of messages popup
#	message_popup_instance.position -= Vector2(
#		200 + popup_groups.get_child_count(),
#		200 + popup_groups.get_child_count()
#	)
	popup_groups.add_child(message_popup_instance)
	
	# first come, first serve
	popup_groups.move_child(message_popup_instance, 0)
	
	message_popup_instance.set_msg(msg)
	
	pass

func _get_popups_group() -> Control:

	if get_tree().root.has_node('/root/PopupsGroup'):
		return get_tree().root.get_node('/root/PopupsGroup')
	
	var popup_groups = Control.new()
	popup_groups.name = "PopupsGroup"
	
	popup_groups.global_position = get_viewport().get_visible_rect().size / 2 
	get_tree().root.get_child(get_tree().root.get_child_count() - 1).add_child(popup_groups)
	return popup_groups
