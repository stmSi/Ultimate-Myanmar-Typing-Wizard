extends Control

@onready var follow_up_rich_text: RichTextLabel = %FollowUpRichText
@onready var line_edit: LineEdit = %LineEdit
@onready var status: Label = $VBoxContainer/HBoxContainer/Status
@onready var t_esting: Label = $VBoxContainer/TEsting

var current_text = ''

var _eng_to_mm_converted = false

func _ready():
	EventBus.finished_section.connect(self._finished_section)
	EventBus.finished_all_sections.connect(self._finished_all_sections)
	
	_start_exercise()


func _start_exercise():
	TextLoader.load_dir_contents(GlobalHardCoded.basic_lessons_location)
	TextLoader.load_file(TextLoader.text_files[2]) # TODO: should select Lesson from UI?
	current_text = TextLoader.load_section()
	EventBus.assign_text.emit(current_text)
	EventBus.current_char_changed.emit(current_text[0])



func _finished_section():
	current_text = TextLoader.load_section()
	if current_text == '':
		EventBus.finished_all_sections.emit()
		return
	EventBus.assign_text.emit(current_text)


func _finished_all_sections():
	$RestartDialog.show()


func _on_text_edit_text_changed(_t: String) -> void:
	if not _eng_to_mm_converted:
		_eng_to_mm_converted = true
		line_edit.text = EngToMmConverter.convert_str(_t)
		line_edit.caret_column = len(line_edit.text)
		
	
	_eng_to_mm_converted = false
	
	##### Status Update #####
	if current_text.begins_with(line_edit.text):
		status.text = "OK"
	else:
		status.text = "Error"

	###### Update Next Char ######
	var l = len(line_edit.text)
	if l < len(current_text):
		EventBus.current_char_changed.emit(current_text[l])
	
	###### Determine Finish Section #########
	if current_text != '' and current_text == line_edit.text:
		EventBus.finished_section.emit()
	
	

func _on_accept_dialog_confirmed() -> void:
	_start_exercise()
