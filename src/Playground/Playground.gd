extends Control

@onready var follow_up_rich_text: RichTextLabel = %FollowUpRichText

@onready var line_edit: LineEdit = %LineEdit
@onready var status: Label = %Status

var current_exercise_text = ''

var _eng_to_mm_converted = false

var lesson_ids = []
var lesson_idx = 0

var exercises = []
var exercise_idx = 0


var difficulty = 'basic'

func _ready():
	EventBus.finished_section.connect(self._load_exercise)
	EventBus.finished_all_sections.connect(self._finished_all_sections)

	_start_lesson()

func _start_lesson():
	lesson_ids = []
	exercises = []
	lesson_idx = 0
	exercise_idx = 0

	var files: PackedStringArray = LessonAccess.get_lesson_files(difficulty)
	if files.size() == 0:
		EventBus.message_popup.emit(
			"Error: difficulty '" \
			+ difficulty.capitalize() \
			+ "' is has no lessons. \r\n" + \
			"Use Exercise Editor to create Lessons and Exercises."
		)
		return
	files.sort()
	for f in files:
		lesson_ids.push_back(f.get_basename().get_file())
	_load_exercise()

func _load_exercise():
	if exercises.size() == exercise_idx:
		if lesson_ids.size() == lesson_idx:
			EventBus.finished_all_sections.emit()
			return
		else:
			exercises = LessonAccess.get_exercise_lines(int(lesson_ids[lesson_idx]), difficulty)
			EventBus.message_popup.emit("Lesson ID: " + lesson_ids[lesson_idx] + " is loaded.")
			lesson_idx += 1

			EventBus.lesson_id_loaded.emit(int(lesson_ids[lesson_idx]))
			
			
			if exercises.size() == exercise_idx:
				# keep loading lessons one by one until there is exercise 
				# otherwise restart with `EventBus.finished_all_sections.emit()`
				_load_exercise() 
				return
	
	
	current_exercise_text = exercises[exercise_idx]
	exercise_idx += 1
	
	EventBus.exercise_loaded.emit(current_exercise_text)
	EventBus.current_char_changed.emit(current_exercise_text[0])


func _finished_all_sections():
#	$RestartDialog.show()
	EventBus.message_popup.emit("All Lessons learned. Restarting...")
	_start_lesson()


func _on_text_edit_text_changed(_t: String) -> void:
	if not _eng_to_mm_converted:
		_eng_to_mm_converted = true
		line_edit.text = EngToMmConverter.convert_str(_t)
		line_edit.caret_column = len(line_edit.text)
		
	_eng_to_mm_converted = false
	
	##### Status Update #####
	if current_exercise_text.begins_with(line_edit.text):
		status.text = "OK"
	else:
		status.text = "Error"

	###### Update Next Char ######
	var l = len(line_edit.text)
	if l < len(current_exercise_text):
		EventBus.current_char_changed.emit(current_exercise_text[l])
	
	EventBus.written_string_changed.emit(line_edit.text)
	
	###### Determine Finish Section #########
	if current_exercise_text != '' and current_exercise_text == line_edit.text:
		EventBus.finished_section.emit()	


func _on_basic_btn_pressed() -> void:
	difficulty = 'basic'
	_start_lesson()
	pass # Replace with function body.


func _on_intermediate_btn_pressed() -> void:
	difficulty = 'intermediate'
	_start_lesson()	
	pass # Replace with function body.


func _on_advanced_btn_pressed() -> void:
	difficulty = 'advanced'
	_start_lesson()
	pass # Replace with function body.
