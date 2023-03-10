extends Control

@onready var follow_up_rich_text: RichTextLabel = %FollowUpRichText
@onready var follow_up_text_popup: Control = $FollowUpTextPopup

@onready var line_edit: LineEdit = %LineEdit
@onready var status: Label = %Status
@onready var accuracy: AccuracyLabel = %Accuracy
@onready var keyboard: Control = %Keyboard
@onready var char_per_min: Label = %CharPerMin

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
var is_progressing_lesson := true
func _ready():
	EventBus.exercise_line_finished.connect(self._on_exercise_line_finished)
	EventBus.finished_all_difficulty_lessons.connect(self._finished_all_difficulty_lessons)
	EventBus.lesson_finished.connect(
		func(lesson_number: int, difficulty: String):
			UserProfileManager.save_stats(
				accuracy.percentage, 
				char_per_min.cpm,
				lesson_number, difficulty
			)
	)
	
	if is_progressing_lesson:
		_start_lesson_progress()
	else:
		_start_extra_lesson()

func _start_extra_lesson():
	line_edit.grab_focus()
	lesson_ids = []
	exercises = []
	lesson_idx = 0
	exercise_idx = 0
	
	difficulty = "extra"
	

	lesson_idx = 1;
	var next_lesson = LessonAccess.get_extra_exercise(lesson_idx, difficulty)
	if next_lesson == {}:
#			EventBus.message_popup.emit('No More lesson available')
		EventBus.message_popup.emit("Error: No Extra Exercises.")
		return


	var files: PackedStringArray = LessonAccess.get_lesson_files(difficulty)
	files.sort()
	for f in files:
		lesson_ids.push_back(f.get_basename().get_file())
	_load_exercise()


func _start_lesson_progress():
	line_edit.grab_focus()
	lesson_ids = []
	exercises = []
	lesson_idx = 0
	exercise_idx = 0
	
	var lesson_progress := UserProfileManager.load_lesson_progress()
	difficulty = lesson_progress['difficulty']
	
	if lesson_progress['is_finished']:
		var next_lesson = LessonAccess.get_next_lesson(
			lesson_progress['lesson_number'],
			lesson_progress['difficulty']
		)
		if next_lesson == []:
#			EventBus.message_popup.emit('No More lesson available')
			EventBus.message_popup.emit(
				"Error: difficulty '" \
				+ difficulty.capitalize() \
				+ "' is has no lessons. \r\n" + \
				"Use Exercise Editor to create Lessons and Exercises."
			)
			return
		lesson_idx = next_lesson[0] - 1 # index are off by one
		difficulty = next_lesson[1]

	else:
		lesson_idx = lesson_progress['lesson_number'] - 1 # index are off by one

	var files: PackedStringArray = LessonAccess.get_lesson_files(difficulty)
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
	
	keyboard.visible = not lesson_data['hide_keyboard']
	follow_up_text_popup.visible = not lesson_data['hide_keyboard']
	
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
			if lesson_data != {}:
				EventBus.lesson_finished.emit(int(lesson_ids[lesson_idx - 1]), difficulty)
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
	_start_lesson_progress()


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


func _randomize_exercise():
	# PackedStringArray doesn't support shuffle()
	# convert to array, shuffle, and reassign
	randomize()
	var tmp = []
	for e in exercises:
		tmp.append(e)
	tmp.shuffle()
	exercises = PackedStringArray(tmp)
