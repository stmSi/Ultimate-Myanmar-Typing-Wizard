extends Control
@onready var playground: Playground = $Playground

func _ready() -> void:
	playground.start_extra_lesson(true)
