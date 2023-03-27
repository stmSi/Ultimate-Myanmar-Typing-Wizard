extends TextureRect

@export var is_random: bool = false

@export var background_images: Array[Texture2D]


func _ready() -> void:
	randomize()
	print(DisplayServer.window_get_size())
	if is_random:
#		texture
		pass
