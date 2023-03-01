extends Control

@onready var follow_up_rich_text: RichTextLabel = %FollowUpRichText

@onready var line_edit: LineEdit = %LineEdit
@onready var status: Label = %Status
@onready var accuracy: AccuracyLabel = %Accuracy

var current_exercise_text = ''

var _eng_to_mm_converted = false

var lesson_ids = []
var lesson_idx = 0

var lesson_data: Dictionary = {}
var repeats = 0
var allow_mistakes_percent = 80 # percentage
var exercises = []
var exercise_idx = 0


var difficulty = 'basic'

func _ready():
	EventBus.exercise_line_finished.connect(self._on_exercise_line_finished)
	EventBus.finished_all_difficulty_lessons.connect(self._finished_all_difficulty_lessons)
	_start_lesson()

func _start_lesson():
	line_edit.grab_focus()
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

func _on_exercise_line_finished():
	
	_load_exercise()

func _load_lesson():
	if lesson_ids.size() == lesson_idx:
		# No more lesson available
		EventBus.finished_all_difficulty_lessons.emit()
		return

	lesson_data = LessonAccess.get_lesson_data(int(lesson_ids[lesson_idx]), difficulty)
	exercises = lesson_data['texts']
	repeats = lesson_data['repeats']
	allow_mistakes_percent = lesson_data['allow_mistakes']
	
	exercise_idx = 0
	lesson_idx += 1
	if lesson_data['randomize']:
		_randomize_exercise()
	
	if lesson_data['message']:
		EventBus.message_popup.emit(lesson_data['message'])
	
	if exercises.size() == exercise_idx:
		# keep loading lessons one by one until there is exercise 
		_load_lesson()
	else:
		EventBus.lesson_id_loaded.emit(int(lesson_ids[lesson_idx - 1]))
#		EventBus.message_popup.emit(
#			"Difficulty: " + difficulty.capitalize() + "\r\n" +\
#			"Lesson ID: " + lesson_ids[lesson_idx - 1] + " is loaded."
#		)

func _load_exercise():
	# No More Exercise
	if exercises.size() == exercise_idx:
		# Repeat Lesson?
		if exercises.size() > 0 and repeats > 0:
			exercise_idx = 0
			repeats -= 1
		else: # Fetch Next Lesson
			_load_lesson()

	
	current_exercise_text = exercises[exercise_idx]
	exercise_idx += 1
	
	EventBus.exercise_loaded.emit(current_exercise_text)
	EventBus.current_char_changed.emit(current_exercise_text[0])


func _finished_all_difficulty_lessons():
#	$RestartDialog.show()
	var accuracy_txt = "Accuracy: " + \
		"[color=" + accuracy.get_accuracy_color_hex() + "][b]" + \
		("%.2f" % accuracy.percentage) + ' %[/b][/color]'
	
	var msg = accuracy_txt
	
	if accuracy.percentage < allow_mistakes_percent:
		msg += "\r\n" + \
				"Made Too many mistakes."

	EventBus.message_popup.emit(msg)
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
		EventBus.exercise_line_finished.emit()


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

func _randomize_exercise():
	# PackedStringArray doesn't support shuffle()
	# convert to array, shuffle, and reassign
	var tmp = []
	for e in exercises:
		tmp.append(e)
	tmp.shuffle()
	exercises = PackedStringArray(tmp)
