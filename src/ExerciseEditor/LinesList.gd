extends ItemList

signal item_moved
signal delete_item_from_delete_key(idx: int)
signal deselect

func _input(event: InputEvent) -> void:
	if get_selected_items().size() == 0:
		return
	
	if event is InputEventKey and event.is_pressed():
		if event.as_text_physical_keycode() == 'Alt+Up':
			_move_up_selected_item()
			get_tree().root.get_viewport().set_input_as_handled()
			
		elif event.as_text_physical_keycode() == 'Alt+Down':
			_move_down_selected_item()
			get_tree().root.get_viewport().set_input_as_handled()
			
		elif event.as_text_physical_keycode() == 'Delete' and has_focus():
			self.delete_item_from_delete_key.emit(get_selected_items()[0])
			get_tree().root.get_viewport().set_input_as_handled()
			
		elif  event.as_text_physical_keycode() == 'Escape' and has_focus():
			self.deselect.emit()
			get_tree().root.get_viewport().set_input_as_handled()

func _move_up_selected_item():
	var idx = get_selected_items()[0]
	if idx == 0: # index => 0 => at top.... ignore
		return

	move_item(idx, idx - 1)
	self.item_moved.emit()	

func _move_down_selected_item():
	var idx = get_selected_items()[0]
	if idx == item_count - 1: # index =>  => at bottom.... ignore
		return
		
	move_item(idx, idx + 1)
	self.item_moved.emit()

