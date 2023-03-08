extends Button

var origin_text

func _ready() -> void:
	origin_text = self.text

func _on_pressed() -> void:
	self.text = " Not Allowed LOL.. go delete profile yourself in filesystem. "
	await get_tree().create_timer(2.5).timeout
	self.text = origin_text

