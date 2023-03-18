extends Control
class_name KeyButton

@onready var shift_char_lbl: Label = $Panel/ShiftChar
@onready var char_lbl: Label = $Panel/Char
@onready var finger_hightlight: Panel = %FingerHightlight

@export var shift_char: String:
	get:
		return shift_char
	set(value):
		%ShiftChar.text = value
		shift_char = value

var chars_to_highlight_for_fingers = "ေျိ်ြုူး" # asdf jkl;
var highlighted: bool = false

@export var char: String:
	get:
		return char
	set(value):
		char = value
		if chars_to_highlight_for_fingers.contains(value):
			%FingerHightlight.visible = true
			highlighted = true
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

@export var highlight_modulate_color: Color = Color.GREEN
var ori_modulate_char_color: Color
var ori_modulate_shift_char_color: Color

func _ready() -> void:
	ori_modulate_char_color = char_lbl.modulate
	ori_modulate_shift_char_color = shift_char_lbl.modulate


func run_pending(use_shift: bool = false):
	$AnimationPlayer.play('pending')
	if use_shift:
		shift_char_lbl.modulate = highlight_modulate_color
	else:
		char_lbl.modulate = highlight_modulate_color
	
	if char == ' ': # special condition for "Space" key
		shift_char_lbl.modulate = highlight_modulate_color
		get_node('line').modulate = highlight_modulate_color # only "Space" key has line

func reset_animation():
	$AnimationPlayer.play("RESET")
	_reset_modulate_color()

func correct_animation():
	$AnimationPlayer.play('correct')
	_reset_modulate_color()


func incorrect_animation():
	$AnimationPlayer.play('incorrect')
	_reset_modulate_color()


func _reset_modulate_color():
	char_lbl.modulate = ori_modulate_char_color
	shift_char_lbl.modulate = ori_modulate_shift_char_color
	
	if char == ' ': # special condition for "Space" key
		get_node('line').modulate = ori_modulate_shift_char_color # only "Space" key has line

func highlight_character(c: String, highlight_color: Color):
	# used by frequent_mistakes_report
	if char_lbl.text == c:
		char_lbl.modulate = highlight_color
	elif shift_char_lbl.text == c:
		shift_char_lbl.modulate = highlight_color
