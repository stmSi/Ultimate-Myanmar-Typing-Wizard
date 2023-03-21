extends Control
@onready var playground: Playground = $Playground

func _ready() -> void:
	playground.start_lesson_progress()
	playground.next_practice_btn.visible = false
