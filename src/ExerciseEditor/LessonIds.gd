extends ItemList

signal swap_lesson(lesson1: int, lesson2: int)
signal delete_lesson_from_delete_key(idx: int)

func _input(event: InputEvent) -> void:
	if get_selected_items().size() == 0:
		return
	
	if event is InputEventKey and event.is_pressed():
		if event.as_text_physical_keycode() == 'Alt+Up':
			_move_up_selected_item()
		elif event.as_text_physical_keycode() == 'Alt+Down':
			_move_down_selected_item()
		elif event.as_text_physical_keycode() == 'Delete' and has_focus():
			self.delete_lesson_from_delete_key.emit(get_selected_items()[0])

func _move_up_selected_item():
	var idx = get_selected_items()[0]
	if idx == 0: # index => 0 => at top.... ignore
		return

	self.swap_lesson.emit(idx, idx - 1)

func _move_down_selected_item():
	var idx = get_selected_items()[0]
	if idx == item_count - 1: # index =>  => at bottom.... ignore
		return

	self.swap_lesson.emit(idx, idx + 1)

