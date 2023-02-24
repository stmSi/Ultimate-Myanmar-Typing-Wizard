extends Control

var key_node_mapping: Dictionary = {}
var current_char: String = ''

var pending_node: KeyButton = null
var pending_shift_node: KeyButton = null

@onready var l_shift: KeyButton = $VBoxContainer/zxcvb/LShift
@onready var r_shift: KeyButton = $VBoxContainer/zxcvb/RShift


func _ready() -> void:
	EventBus.current_char_changed.connect(self._on_current_char_changed)


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
			

		if len(converted_char) > 1: # Shift/Alt/Ctrl
			### Allow 'Backkspace' and 'Delete'
			if converted_char != "Backspace" and converted_char != "Delete" and converted_char != "Simicolon":
				return
		
		if current_char == converted_char:
			pending_node.correct_animation()
			
			if pending_shift_node:
				pending_shift_node.correct_animation()
				
		else:
			_run_incorrect(converted_char)
			pending_node.reset_animation()
		

func _on_current_char_changed(char: String):
	current_char = char
	pending_shift_node = null
	var shift = TextProcessor.need_shift(current_char)
	if shift == "l_shift":
		_run_pending_l_shift()
	elif shift == "r_shift":
		_run_pending_r_shift()
		

	_run_pending()


func _run_pending():
	if key_node_mapping.has(current_char):
		pending_node = key_node_mapping[current_char]
		pending_node.run_pending()
	pass


func _run_incorrect(char: String):
	if key_node_mapping.has(char):
		var incorrect_node = key_node_mapping[char]
		incorrect_node.incorrect_animation()
		
		var shift = TextProcessor.need_shift(char)
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
	l_shift.reset_animation()
	r_shift.reset_animation()
	pending_shift_node = null
	pass

