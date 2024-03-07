class_name LessonData
extends Resource

var texts: PackedStringArray
var repeats: int
var allow_mistakes: int
var randomize: bool
var hide_keyboard: bool
var message: String

func _init(
	_texts: PackedStringArray = PackedStringArray([]),
	_repeats: int = 0,
	_allow_mistakes: int = 80,
	_randomize: bool = false,
	_hide_keyboard: bool = false,
	_message: String = ""
) -> void:
	texts = _texts
	repeats = _repeats
	allow_mistakes = _allow_mistakes
	randomize = _randomize
	hide_keyboard = _hide_keyboard
	message = _message
