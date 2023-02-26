extends Control

@onready var follow_up_rich_text: RichTextLabel = %FollowUpRichText

@onready var line_edit: LineEdit = %LineEdit
@onready var status: Label = %Status

var current_text = ''

var _eng_to_mm_converted = false


var lesson_ids = []
var exercises = []

func _ready():
	EventBus.finished_section.connect(self._load_exercise)
	EventBus.finished_all_sections.connect(self._finished_all_sections)

	_start_exercise()

func _start_exercise():
	var files = LessonAccess.get_lesson_files('basic')
	files.sort()
	for f in files:
		lesson_ids.push_back(f.get_basename().get_file())
	
	exercises = LessonAccess.get_exercise_lines(int(lesson_ids[0]), 'basic')
	lesson_ids.pop_front()
	_load_exercise()

func _load_exercise():
	if exercises.size() == 0:
		if lesson_ids.size() == 0:
			print('finished_all_sections: ', lesson_ids)
			EventBus.finished_all_sections.emit()
			return
		else:
			exercises = LessonAccess.get_exercise_lines(int(lesson_ids[0]), 'basic')
			lesson_ids.pop_front()
			if exercises.size() == 0:
				_load_exercise() # keep loading lessons one by one until there is exercise
				return
	
	
	current_text = exercises[0]
	exercises.remove_at(0)
	EventBus.assign_text.emit(current_text)
	EventBus.current_char_changed.emit(current_text[0])


func _finished_all_sections():
#	$RestartDialog.show()
	EventBus.message_popup.emit("All Lessons learned. Restarting...")
	_start_exercise()


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
	
	EventBus.written_string_changed.emit(line_edit.text)
	
	###### Determine Finish Section #########
	if current_text != '' and current_text == line_edit.text:
		EventBus.finished_section.emit()	
