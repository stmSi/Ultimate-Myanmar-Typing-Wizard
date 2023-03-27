extends Control

@onready var take_lesson_btn: Button = %TakeLessonBtn


func _ready() -> void:
	var lesson_progress = UserProfileManager.load_lesson_progress()
	var next_lesson = (
		LessonAccess
		. get_next_lesson(
			lesson_progress["lesson_number"],
			lesson_progress["difficulty"],
		)
	)

	if next_lesson == []:
		take_lesson_btn.disabled = true
		take_lesson_btn.tooltip_text = "All Lessons Finished"
