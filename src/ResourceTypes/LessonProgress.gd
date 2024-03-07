extends Resource

class_name LessonProgress

var lesson_number: int
var difficulty: String
var is_finished: bool
var last_time: String

func _init(
	lesson_number: int = 1,
	difficulty: String = "basic",
	is_finished: bool = false,
	last_time: String = Time.get_datetime_string_from_system()
) -> void:
	self.lesson_number = lesson_number
	self.difficulty = difficulty
	self.is_finished = is_finished
	self.last_time = last_time
