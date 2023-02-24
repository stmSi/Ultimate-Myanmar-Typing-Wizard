extends Control
class_name KeyButton

@onready var shift_char_lbl: Label = $Panel/ShiftChar
@onready var char_lbl: Label = $Panel/Char

@export var shift_char: String:
	get:
		return shift_char
	set(value):
		%ShiftChar.text = value

@export var char: String:
	get:
		return char
	set(value):
		%Char.text = value


@onready var is_char_ascii: bool = false:
	get:
		return is_char_ascii
#	set(value):
#		(%Char as Label).position = Vector2(55, 35)


@onready var is_shift_char_ascii: bool = false:
	get:
		return is_shift_char_ascii
#	set(value):"theme_override_styles/panel"
#		(%ShiftChar as Label).position = Vector2(10, 10)

func run_pending():
	$AnimationPlayer.play('pending')
	
func reset_animation():
	pass
	$AnimationPlayer.play("RESET")

func correct_animation():
	$AnimationPlayer.play('correct')


func incorrect_animation():
	$AnimationPlayer.play('incorrect')
