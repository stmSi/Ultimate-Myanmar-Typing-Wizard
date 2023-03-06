extends TextureRect

@export var is_random: bool = false

@export var background_images: Array[Texture2D]

func _ready() -> void:
	randomize()
	if is_random:
		texture
