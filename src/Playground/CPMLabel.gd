extends Label
class_name CPMLabel

var max_chars_to_calculate := 20
var times_taken : Array[float] = []
var last_time_char_typed := 0.0
var cpm := "0"


func _ready() -> void:
	EventBus.wrong_char_typed.connect(
		func(_wrong_c: String, _correct_c: String) -> void:
			self._calculate_time_taken()
	)

	EventBus.correct_char_typed.connect(
		func(_correct_c: String) -> void:
			self._calculate_time_taken()
	)

	EventBus.lesson_finished.connect(
		func(_l: int, _d: String) -> void:
			times_taken = []
			last_time_char_typed = 0.0
			self.text = '0'
	)

	EventBus.finished_all_difficulty_lessons.connect(
		func() -> void:
			times_taken = []
			last_time_char_typed = 0.0
			self.text = '0'
	)

func _calculate_time_taken() -> void:
	var now_in_minute := (Time.get_ticks_msec() / 1000.0) / 60

	if last_time_char_typed != 0:
		times_taken.push_back(now_in_minute - last_time_char_typed)
		var total_in_sec := 0.0
		for t in times_taken:
			total_in_sec += t
		if total_in_sec != 0:
			cpm = str(roundf(times_taken.size() / (total_in_sec)))
		self.text = cpm

	if times_taken.size() > max_chars_to_calculate:
		times_taken.pop_front()

	last_time_char_typed = now_in_minute
