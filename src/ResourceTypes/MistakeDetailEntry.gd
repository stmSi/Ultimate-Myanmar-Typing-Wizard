class_name MistakeDetailEntry
extends Resource

var wrong_char: String
var frequency: int
var last_time: String

func _init(_wrong_char: String, _frequency: int, _last_time: String) -> void:
	wrong_char = _wrong_char
	frequency = _frequency
	last_time = _last_time
