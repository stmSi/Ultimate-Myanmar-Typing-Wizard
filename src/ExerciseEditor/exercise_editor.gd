extends Control

@onready var basic_btn: Button = %BasicBtn
@onready var intermediate_btn: Button = %IntermediateBtn
@onready var advance_btn: Button = %AdvancedBtn

@onready var lesson_ids_lbl: Label = %LessonIdsLbl
@onready var lesson_ids: ItemList = %LessonIds

@onready var lines_list: ItemList = %LinesList

@onready var line_edit: LineEdit = %LineEdit

@onready var add_updte_line_btn: Button = %AddUpdteLineBtn
@onready var remove_line_btn: Button = %RemoveLineBtn

var selected_difficulty: String = '';
var selected_lesson_number: int = 0;
var selected_line_idx: int = -1

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass

func _on_basic_btn_pressed() -> void:
	lesson_ids_lbl.text = '"Basic" Files:'
	selected_difficulty = 'basic'
	_populate_files_list()


func _on_intermediate_btn_pressed() -> void:
	lesson_ids_lbl.text = '"Intermediate" Files:'
	selected_difficulty = 'intermediate'
	_populate_files_list()


func _on_advance_btn_pressed() -> void:
	lesson_ids_lbl.text = '"Advanced" Files:'
	selected_difficulty = 'advanced'
	_populate_files_list()


func _on_cancel_btn_pressed() -> void:
	lesson_ids_lbl.text = 'No Difficulty Selected'
	selected_difficulty = ''
	lesson_ids.clear()


func _populate_files_list() -> void:
	lesson_ids.clear()
	var files = LessonAccess.get_lesson_files(selected_difficulty)
	files.sort()
	for f in files:
		lesson_ids.add_item(f.get_basename().get_file())
#		lesson_ids.set_item_metadata(-1, f)
	
	# Scroll to bottom
	if len(files) > 0:
		lesson_ids.select(files.size() - 1)
		lesson_ids.ensure_current_is_visible() 
		lesson_ids.deselect_all()
	
	# Reset lines_list, line_edit, button
	_on_lines_list_empty_clicked(Vector2.ZERO, -1)
	lines_list.clear()


func _on_add_lessons_file_btn_pressed() -> void:
	if selected_difficulty == '':
		EventBus.message_popup.emit('Please Choose Difficulty')
		return

	var lesson_number: int = 1 # Default Start number
	var files: PackedStringArray = LessonAccess.get_lesson_files(selected_difficulty)
	files.sort()
	if len(files) > 0:
		var last_file = files[files.size() - 1]
		lesson_number = int(last_file.get_basename().get_file()) + 1 # next number
	
	var success = LessonAccess.create_new_lesson_file(lesson_number, selected_difficulty)
	if success:
		_populate_files_list()


func _on_lesson_ids_item_selected(index: int) -> void:
	selected_lesson_number = int(lesson_ids.get_item_text(index))
	
	var lines: PackedStringArray = LessonAccess.get_exercise_lines(selected_lesson_number, selected_difficulty)
	lines_list.clear()
	for l in lines:
		lines_list.add_item(l)
#	
	# Scroll to bottom
	if len(lines) > 0:
		lines_list.select(len(lines) - 1)
		lines_list.ensure_current_is_visible() 
		lines_list.deselect_all()
	
	# Reset lines_list, line_edit, button
	_on_lines_list_empty_clicked(Vector2.ZERO, -1)


func _on_lines_list_item_selected(index: int) -> void:
	line_edit.text = lines_list.get_item_text(index)
	
	selected_line_idx = index
	add_updte_line_btn.text = "Update Line"
	pass # Replace with function body.


func _on_lines_list_empty_clicked(_at_position: Vector2, _mouse_button_index: int) -> void:
	# Reset lines_list, line_edit, button
	line_edit.text = ''
	selected_line_idx = -1
	add_updte_line_btn.text = "Add Line"
	lines_list.deselect_all()
	pass # Replace with function body.


func _on_line_edit_text_submitted(_new_text: String) -> void:
	_on_add_updte_line_btn_pressed()
	pass # Replace with function body.


func _on_add_updte_line_btn_pressed() -> void:
	if selected_line_idx != -1:
		# Update
		lines_list.set_item_text(lines_list.get_selected_items()[0], line_edit.text)
	else:
		# Add
		lines_list.add_item(line_edit.text)
	_save_lesson_from_list()
	
	# Reset shit
	_on_lines_list_empty_clicked(Vector2.ZERO, -1)



func _on_remove_line_btn_pressed() -> void:
	if lines_list.get_selected_items().size() == 0:
		return
	var idx := lines_list.get_selected_items()[0]
	lines_list.remove_item(idx)

	# Reset shit
	_on_lines_list_empty_clicked(Vector2.ZERO, -1)
	
	if lines_list.item_count > 0:
		var next_selected_idx = min(lines_list.item_count - 1, idx )
		lines_list.select(next_selected_idx)
	_save_lesson_from_list()



func _on_reset_btn_pressed() -> void:
	# Reset
	_on_lines_list_empty_clicked(Vector2.ZERO, -1)
	pass # Replace with function body.


func _on_lines_list_item_moved() -> void:
	_save_lesson_from_list()
	pass # Replace with function body.

func _save_lesson_from_list():
	var texts: PackedStringArray = []
	
	var i = 0
	while i < lines_list.item_count:
		texts.push_back(lines_list.get_item_text(i))
		i += 1

	LessonAccess.create_update_new_exercise(
		selected_lesson_number,
		selected_difficulty,
		texts
	)
	


func _on_lines_list_delete_item_from_delete_key(idx) -> void:
	_on_remove_line_btn_pressed()
	pass # Replace with function body.
