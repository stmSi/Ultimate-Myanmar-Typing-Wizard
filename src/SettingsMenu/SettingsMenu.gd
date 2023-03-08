extends Control

@onready var margin_container: MarginContainer = $MarginContainer
var main_tween : Tween

func _ready() -> void:
	EventBus.open_settings_menu.connect(self._open)

	visible = false

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventKey and event.is_pressed():
		if event.as_text_physical_keycode() == 'Escape':
			if visible:
				_close()
			else:
				_open()
			

func _open():
	for n in get_tree().get_nodes_in_group('appear_animate'):
		n.modulate.a = 0
	var node = margin_container
	node.scale = Vector2(0, 0)
	node.modulate = Color(0, 0, 0, 0)
	
	visible = true
	
	main_tween = get_tree().create_tween()
	main_tween.set_parallel(true)
	main_tween.tween_property(node, "modulate", Color.WHITE, .3)
	main_tween.tween_property(node, "scale", Vector2(1,1), .3)
	
	await main_tween.finished
	for n in get_tree().get_nodes_in_group('appear_animate'):
		var tween = get_tree().create_tween()
		tween.tween_property(n, "modulate", Color.WHITE, .15)
		await tween.finished

func _close():
	var node = margin_container
	for n in get_tree().get_nodes_in_group('appear_animate'):
		var tween = get_tree().create_tween()
		tween.tween_property(n, "modulate", Color(1, 1, 1, 0), .15)
		await tween.finished
	
	main_tween = get_tree().create_tween()
	main_tween.set_parallel(true)
	main_tween.tween_property(node, "modulate", Color(1, 1, 1, 0), .3)
	main_tween.tween_property(node, "scale", Vector2.ZERO, .3)
	await main_tween.finished
	visible = false


func _on_quit_to_menu_pressed() -> void:
	SceneChanger.change_to_main_scene()
	pass # Replace with function body.
