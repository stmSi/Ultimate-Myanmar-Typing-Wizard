extends Node

var lesson_name_width = 8

func _ready() -> void:
	pass
	
func create_new_lesson_file(lesson_number: int, difficulty: String) -> bool:
	var filepath = _get_lesson_filepath(lesson_number, difficulty)
	
	var blank_array: PackedStringArray = []
	
	var config: ConfigFile = ConfigFile.new()
	
	config.set_value("Exercise", "texts", blank_array)
	
	var error = config.save(filepath)
	if error != OK:
		EventBus.message_popup.emit('Error occurred while saving/creating lesson file: ' + filepath)
		return false

	return true

func create_update_new_exercise(lesson_number: int, difficulty: String, texts: PackedStringArray) -> bool:
	var filepath = _get_lesson_filepath(lesson_number, difficulty)
	
	var config: ConfigFile = ConfigFile.new()
	config.set_value("Exercise", "texts", texts)

	var error = config.save(filepath)
	if error != OK:
		EventBus.message_popup.emit('Error occurred while saving/creating exercise: ' + filepath)
		return false
	return true

func get_lesson_files(difficulty: String) -> PackedStringArray:
	var difficulty_lesson_path = _determine_difficulty_lessons_path(difficulty)
	if difficulty_lesson_path == '':
		return []
	
	var text_files = []

	var dir = DirAccess.open('./')
	if not dir.dir_exists(difficulty_lesson_path):
		dir.make_dir_recursive(difficulty_lesson_path)
	
	dir = DirAccess.open(difficulty_lesson_path)
		
	if dir:
		dir.list_dir_begin()
		var file_name = dir.get_next()
		while file_name != "":
			if not dir.current_is_dir():
				text_files.append(dir.get_current_dir().path_join(file_name))
			file_name = dir.get_next()
	else:
		EventBus.message_popup.emit("An error occurred when trying to access the lessons path: " + difficulty_lesson_path)
	return text_files


func get_exercise_lines(lesson_number: int, difficulty: String) -> PackedStringArray:
	var filepath = _get_lesson_filepath(lesson_number, difficulty)
	var config: ConfigFile = ConfigFile.new()
	var error = config.load(filepath)
	if error != OK:
		EventBus.message_popup.emit('Error occurred while loading config: ' + filepath)
		return []
	
	if not config.has_section('Exercise'):
		EventBus.message_popup.emit('Can\'t find \'Exercise\' Section: ' + filepath)
		return []
	
	return config.get_value('Exercise', 'texts') # ['က', 'ခ', 'ဂ']


func _get_lesson_filepath(lesson_number: int, difficulty: String) -> String:
	# return -> ./Texts/Lessons/Basic/00000113.cfg
	var difficulty_lesson_path = _determine_difficulty_lessons_path(difficulty)
	if difficulty_lesson_path == '':
		return ''

	var filename = _craft_lesson_filename(lesson_number)
	var filepath = difficulty_lesson_path.path_join(filename)
	return filepath
	

func _determine_difficulty_lessons_path(difficulty: String) -> String:
	if difficulty == "basic":
		return GlobalHardCoded.basic_lessons_location
	elif difficulty == "intermediate":
		return GlobalHardCoded.intermediate_lessons_location
	elif difficulty == "advanced":
		return GlobalHardCoded.advanced_lessons_location
	else:
		EventBus.message_popup.emit('Please Choose Difficulity')
		return ''


func _craft_lesson_filename(lesson_number: int) -> String:
	# 23 -> "00000023.cfg"
	
	var filename = ""
	
	var len_zeroes = lesson_name_width - len(str(lesson_number))
	var i = 0
	while i < len_zeroes:
		filename += "0"
		i += 1
	
	filename += str(lesson_number) + ".cfg"
	
	return filename
