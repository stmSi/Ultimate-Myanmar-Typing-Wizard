extends Label

var max_chars_to_calculate = 20
var times_taken = []
var last_time_char_typed = 0.0
var cpm = 0

@onready var player: Control = $"../../../../../.."

func _ready() -> void:
	if label_settings:
		label_settings = label_settings.duplicate(true)
	if player.player_id == multiplayer.get_unique_id():
		EventBus.wrong_char_typed.connect(
			func(_wrong_c: String, _correct_c: String):
				self._calculate_time_taken()
		)
		
		EventBus.correct_char_typed.connect(
			func(_correct_c: String):
				self._calculate_time_taken()
		)

func _calculate_time_taken():
	var now_in_minute = (Time.get_ticks_msec() / 1000.0) / 60

	if last_time_char_typed != 0:
		times_taken.push_back(now_in_minute - last_time_char_typed)
		var total_in_sec = 0
		for t in times_taken:
			total_in_sec += t
		
		cpm = str(roundf(times_taken.size() / (total_in_sec)))
		self.text = cpm
	
	if times_taken.size() > max_chars_to_calculate:
		times_taken.pop_front()

	last_time_char_typed = now_in_minute

