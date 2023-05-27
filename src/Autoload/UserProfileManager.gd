extends Node

# /home/stm/.local/share/godot/app_userdata/Ultimate Myanmar Typing Wizard/
var profile_data_file = "user://user_profile_data.cfg"
var save_file : ConfigFile
var mistakes = {
	"correct_chars": [],
	"wrong_chars": [],
	"timestamps": [],
}

var corrected_chars = []
var corrected_chars_frequency = []


func _ready() -> void:
	Utils.check_and_create_user_dir()
	if not FileAccess.file_exists(profile_data_file):
		save_file = ConfigFile.new()
		# save Default data
		save_file.set_value("LessonProgress", "difficulty", "basic")
		save_file.set_value("LessonProgress", "lesson_number", 1)
		save_file.set_value("LessonProgress", "is_finished", false)
		save_file.set_value("LessonProgress", "last_time", Time.get_datetime_string_from_system())
		
		save_file.save(profile_data_file)
	
	EventBus.correct_char_typed.connect(
		func(correct_c: String):
			var idx = corrected_chars.find(correct_c)
			if idx == -1:
				corrected_chars.push_back(correct_c)
				corrected_chars_frequency.push_back(1)
			else:
				corrected_chars_frequency[idx] += 1
	)

	EventBus.wrong_char_typed.connect(func(wrong_char: String, correct_char: String):
		mistakes["correct_chars"].append(correct_char)
		mistakes["wrong_chars"].append(wrong_char)
		mistakes["timestamps"].append(Time.get_datetime_string_from_system())
	)
	
	EventBus.lesson_finished.connect(func(lesson_number: int, difficulty: String):
		
		save_correct_characters()
		corrected_chars = []
		corrected_chars_frequency = []
		
		save_mistake_details(mistakes["correct_chars"], mistakes["wrong_chars"], mistakes["timestamps"])
		# reset mistakes
		mistakes = {
			"correct_chars": [],
			"wrong_chars": [],
			"timestamps": [],
		}
		
		if difficulty == "extra":
			return # don't save lesson progress on extra practice
		save_lesson_progress(lesson_number, difficulty, true)
	)
	
	
	
func save_lesson_progress(lesson_number: int, difficulty: String, is_finished: bool) -> bool:
	if not save_file:
		save_file = ConfigFile.new()

	var err = save_file.load(profile_data_file)
	if err != OK:
		print("Error in _save_lesson_progress: loading data fails.")
		return false;
	
	save_file.set_value("LessonProgress", "difficulty", difficulty)
	save_file.set_value("LessonProgress", "lesson_number", lesson_number)
	save_file.set_value("LessonProgress", "is_finished", is_finished)
	save_file.set_value("LessonProgress", "last_time", Time.get_datetime_string_from_system())
	
	err = save_file.save(profile_data_file)
	if err != OK:
		print("Error in _save_lesson_progress: save data fails.")
		return false;
	return true


func load_lesson_progress() -> Dictionary:
	if not save_file:
		save_file = ConfigFile.new()
	
	var err = save_file.load(profile_data_file)
	if err != OK:
		print("Error in _load_lesson_progress: Returning default values.")
		return {
			"lesson_number": 1,
			'difficulty': 'basic',
			'is_finished': false,
			'last_time' : Time.get_datetime_string_from_system(),
		}
	
	var lesson_progress : Dictionary = {}
	
	lesson_progress['lesson_number'] = save_file.get_value(
		"LessonProgress", 
		"lesson_number", 
		1
	)
	lesson_progress['difficulty'] = save_file.get_value(
		"LessonProgress", 
		"difficulty", 
		"basic"
	)
	lesson_progress['is_finished'] = save_file.get_value(
		"LessonProgress", 
		"is_finished", 
		false,
	)
	lesson_progress['last_time'] = save_file.get_value(
		"LessonProgress", 
		"last_time", 
		Time.get_datetime_string_from_system()
	)
	return lesson_progress


func save_mistake_details(
	correct_chars: Array, 
	wrong_chars: Array, 
	timestamps: Array) -> bool:
	# Save string which trainee used to confused.
	if not save_file:
		save_file = ConfigFile.new()
	
	if len(correct_chars) != len(wrong_chars) || len(wrong_chars) != len(timestamps):
		print("Error in save_mistake_details: wrong parameter lengths.")
		return false
	
	var err = save_file.load(profile_data_file)
	if err != OK:
		print("Error in save_mistake: loading save file data fails.")
		return false;
	
	var i := 0
	while(i < len(correct_chars)):
		var correct_char = correct_chars[i]
		var wrong_char = wrong_chars[i]
		var timestamp = timestamps[i]
		# [Mistakes]
		# "correct_char"=[
		# 	{wrong_char: how_many_times, "last_time": last_time_mistake}, 
		# 	{another_w_char: how_many_times, "last_time": last_time_mistake}
		#	]
		
		var mistake_char_data : Array = save_file.get_value("MistakesDetails", correct_char, [] )
		
		var j := 0;
		while j < len(mistake_char_data):
			if mistake_char_data[j].has(wrong_char):
				mistake_char_data[j][wrong_char] += 1
				mistake_char_data[j]['last_time'] = timestamp
				break
			j += 1
		
		if j == len(mistake_char_data):
			# Not found wrong_char, first time wrong
			mistake_char_data.append({
				wrong_char: 1,
				"last_time": Time.get_datetime_string_from_system()
			})
	
		
		save_file.set_value("MistakeDetails", correct_char, mistake_char_data)
		i += 1
		
	err = save_file.save(profile_data_file)
	if err != OK:
		print("Error in save_mistake: Saving/Updating profile data")
		return false
		
	return true


func load_mistake_details() -> Array:
	# 
	# [
	#	{"correct_char":
	#	 	[
	#		 	{wrong_char: how_many_times, "last_time": last_time_mistake}, 
	#		 	{another_w_char: how_many_times, "last_time": last_time_mistake}
	#		]
	#	},
	#	{"another_correct_char" : [
	# 		{wrong_char: how_many_times, "last_time": last_time_mistake}, 
	# 		{another_w_char: how_many_times, "last_time": last_time_mistake}
	#	]},
	# ]
	var _mistakes = []
	if not save_file:
		save_file = ConfigFile.new()

	var err = save_file.load(profile_data_file)
	if err != OK:
		print("Error in load_mistake_details: loading save file data fails.")
		return [];
	
	var correct_chars = save_file.get_section_keys("MistakeDetails")
	for c in correct_chars:
		_mistakes.append({
			c: save_file.get_value("MistakeDetails", c, []) 
		})
	
	return _mistakes


func save_correct_characters() -> bool:
	if len(corrected_chars) != len(corrected_chars_frequency):
		print("Error in save_correct_characters: incorrect parameter lengths.")
		return false

	if not save_file:
		save_file = ConfigFile.new()
		
	var err = save_file.load(profile_data_file)
	if err != OK:
		print("Error in save_correct_characters: loading save file data fails.")
		return false;
	
	var i := 0
	while(i < len(corrected_chars)):
		# [Corrects]
		# "correct_char"=total_corrected_char_freq
		# ....
		var corrected_char = corrected_chars[i]
		var total_corrected_char_freq : int = \
			save_file.get_value("Corrects", corrected_char, 0) \
			+ \
			corrected_chars_frequency[i]
		save_file.set_value("Corrects", corrected_char, total_corrected_char_freq)
		i += 1
		
	err = save_file.save(profile_data_file)
	if err != OK:
		print("Error in save_correct_characters: Saving/Updating profile data")
		return false
		
	return true


func load_correct_characters() -> Array:
	# [Corrects]
	# "correct_char"=total_corrected_char_freq
	# ....
	var corrected_chars = []
	if not save_file:
		save_file = ConfigFile.new()

	var err = save_file.load(profile_data_file)
	if err != OK:
		print("Error in load_mistake_details: loading save file data fails.")
		return [];
	
	var chars = save_file.get_section_keys("Corrects")
	for c in chars:
		corrected_chars.append({
			c: save_file.get_value("Corrects", c, 0) 
		})
	
	return corrected_chars




func save_stats(accuracy: float, char_per_min: int, lesson_number: int, difficulty: String) -> bool:
	if not save_file:
		save_file = ConfigFile.new()
	
	var err = save_file.load(profile_data_file)
	if err != OK:
		print("Error in save_stats: loading save file data fails.")
		return false;
	
	save_file.set_value("Statistics", 
		Time.get_datetime_string_from_system(), 
		{
			"accuracy": accuracy,
			"char_per_min": char_per_min,
			"lesson_number": lesson_number,
			"difficulty": difficulty
		}
	)
	
	err = save_file.save(profile_data_file)
	if err != OK:
		print("Error in save_stats: saving/updating stats in profile fails.")
		return false;
	
	return true


func load_stats() -> Array:
	var stats = []
	if not save_file:
		save_file = ConfigFile.new()

	var err = save_file.load(profile_data_file)
	if err != OK:
		print("Error in load_stats: loading save file data fails.")
		return [];
	
	var stats_timestamp = save_file.get_section_keys("Statistics")
	for timestamp in stats_timestamp:
		stats.append({
			timestamp: save_file.get_value("Statistics", timestamp, {}) 
		})
	
	return stats


func reset_progress():
	if not save_file:
		save_file = ConfigFile.new()

	var err = save_file.load(profile_data_file)
	if err != OK:
		print("Error in reset_progress: loading save file data fails.")
		return;
	
	save_file.erase_section("LessonProgress")
	err = save_file.save(profile_data_file)
	if err != OK:
		print("Error in reset_progress: resetting lesson progress fails.")
		return

func reset_statistics():
	if not save_file:
		save_file = ConfigFile.new()
	
	var err = save_file.load(profile_data_file)
	if err != OK:
		print("Error in reset_progress: loading save file data fails.")
		return
	
	save_file.erase_section("Statistics")
	save_file.erase_section("MistakeDetails")
	save_file.erase_section("Corrects")
	
	err = save_file.save(profile_data_file)
	if err != OK:
		print("Error in reset_progress: resetting lesson progress fails.")
		return
		
