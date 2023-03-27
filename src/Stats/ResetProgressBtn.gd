extends Button

var origin_text

var confirm = false


func _ready() -> void:
	origin_text = self.text


func _on_pressed() -> void:
	if not confirm:
		self.text = "Are you sure to Reset Progress?"
	else:
		UserProfileManager.reset_progress()
		SceneChanger.change_to_main_scene()
		return
	confirm = true

	await get_tree().create_timer(3).timeout
	confirm = false
	self.text = origin_text
