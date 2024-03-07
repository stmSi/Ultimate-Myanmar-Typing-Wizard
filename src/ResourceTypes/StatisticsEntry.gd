class_name StatisticEntry
extends Resource

var timestamp: String
var accuracy: float
var char_per_min: int
var difficulty: String
var lesson_number: int

func _init(_timestamp: String, _accuracy: float, _char_per_min: int, _difficulty: String, _lesson_number: int) -> void:
	timestamp = _timestamp
	accuracy = _accuracy
	char_per_min = _char_per_min
	difficulty = _difficulty
	lesson_number = _lesson_number
