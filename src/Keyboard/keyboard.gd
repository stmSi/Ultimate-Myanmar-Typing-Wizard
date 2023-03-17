@icon("res://Assets/Icons/keyboard-icon.png")
extends Control
class_name  Keyboard 

var key_node_mapping: Dictionary = {}
var current_char: String = ''

var pending_node: KeyButton = null
var pending_shift_node: KeyButton = null

@onready var l_shift: KeyButton = $VBoxContainer/zxcvb/LShift
@onready var r_shift: KeyButton = $VBoxContainer/zxcvb/RShift
@onready var space: KeyButton = %space

var ignored_keycodes = [
	'Backspace',
	'Delete',
	'Semicolon',
	'Space'
]

func _ready() -> void:
	key_node_mapping[' '] = space
	EventBus.current_char_changed.connect(self._on_current_char_changed)
	EventBus.lesson_id_loaded.connect(self._on_new_lesson_id_loaded)
	
	EventBus.finished_all_difficulty_lessons.connect(self.reset_all_keys)

func _on_new_key_node_added(key_name, node) -> void:
	key_node_mapping[key_name] = node


func _input(event: InputEvent) -> void:
	if current_char == '':
		return
	
	if pending_node and event is InputEventKey and event.is_pressed():
		var keycode_str = OS.get_keycode_string(event.keycode)

		## eng -> mm
		var converted_char = EngToMmConverter.convert_char(
			keycode_str, 
			event.shift_pressed
		)[1] ### [Success, Char]
#		print('converted: ' + converted_char)
			

		if len(converted_char) > 1: # Shift/Alt/Ctrl
			### Allow 'Backspace', 'Delete', etc..
			if ignored_keycodes.find(converted_char) == -1:
				return
		
		if converted_char.begins_with("Backsp"): #ignore Backspace
			pending_node.reset_animation()
			_reset_shifts()
			return
		
		elif current_char == converted_char:
			EventBus.correct_char_typed.emit(converted_char)
			pending_node.correct_animation()
			
			if pending_shift_node:
				pending_shift_node.correct_animation()
		else:
			EventBus.wrong_char_typed.emit(converted_char, current_char)
			_run_incorrect(converted_char)
			reset_all_keys()
		

func _on_current_char_changed(c: String):
	current_char = c
	pending_shift_node = null
	var shift = TextProcessor.need_shift(current_char)
	if shift == "l_shift":
		_run_pending_l_shift()
	elif shift == "r_shift":
		_run_pending_r_shift()
		
	
	_run_pending(len(shift) != 0)


func _run_pending(use_shift: bool):
	if key_node_mapping.has(current_char):
		pending_node = key_node_mapping[current_char]

		# calculate Center of key_button
		var pos = Vector2(
			pending_node.global_position.x + (pending_node.size.x / 2), 
			pending_node.global_position.y
		)
		EventBus.followup_popup_pos_changed.emit(pos, pending_node)
		
		pending_node.run_pending(use_shift)
	pass


func _run_incorrect(c: String):
	if key_node_mapping.has(c):
		var incorrect_node = key_node_mapping[c]
		incorrect_node.incorrect_animation()
		
		var shift = TextProcessor.need_shift(c)
		if shift == "l_shift":
			l_shift.incorrect_animation()
		elif shift == "r_shift":
			r_shift.incorrect_animation()
			

func _run_pending_l_shift():
	pending_shift_node = l_shift
	l_shift.run_pending();

func _run_pending_r_shift():
	pending_shift_node = r_shift
	r_shift.run_pending();


func _reset_shifts():
	if l_shift:
		l_shift.reset_animation()
	if r_shift:
		r_shift.reset_animation()
	pending_shift_node = null
	pass

func _on_new_lesson_id_loaded(_lesson_number: int) -> void:
	# Reset all
	reset_all_keys()

func reset_all_keys():
	if pending_node:
		pending_node.reset_animation()
	_reset_shifts()
	
