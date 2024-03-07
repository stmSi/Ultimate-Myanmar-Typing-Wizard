class_name CharacterMistakeDetails
extends Resource

var correct_char: String
var mistakes: Array[MistakeDetailEntry]

func _init(_correct_char: String, _mistakes: Array[MistakeDetailEntry]) -> void:
	correct_char = _correct_char
	mistakes = _mistakes
