extends Label

var max_chars_to_calculate: int = 20
var times_taken: Array[float] = []
var last_time_char_typed: float = 0.0
var cpm: int = 0

@onready var player: Player = $"../../../../../.."


func _ready() -> void:
	if label_settings:
		label_settings = label_settings.duplicate(true)
	if player.player_id == multiplayer.get_unique_id():
		EventBus.wrong_char_typed.connect(
			func(_wrong_c: String, _correct_c: String) -> void:
				self._calculate_time_taken()
		)

		EventBus.correct_char_typed.connect(
			func(_correct_c: String) -> void:
				self._calculate_time_taken()
		)


func _calculate_time_taken() -> void:
	var now_in_minute: float = (Time.get_ticks_msec() / 1000.0) / 60.0

	if last_time_char_typed != 0.0:
		times_taken.push_back(now_in_minute - last_time_char_typed)
		var total_in_sec: float = 0.0
		for t: float in times_taken:
			total_in_sec += t

		if total_in_sec > 0.0:
			cpm = int(roundf(times_taken.size() / total_in_sec))
			self.text = str(cpm)

	if times_taken.size() > max_chars_to_calculate:
		times_taken.pop_front()

	last_time_char_typed = now_in_minute
