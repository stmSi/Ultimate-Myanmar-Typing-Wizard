extends Node

# /home/stm/.local/share/godot/app_userdata/Ultimate Myanmar Typing Wizard/
var profile_data_file = "user://user_profile_data.cfg"
var save_file : ConfigFile

func _ready() -> void:
	if not FileAccess.file_exists(profile_data_file):
		save_file = ConfigFile.new()
		# save Default data
		save_file.set_value("LessonProgress", "difficulty", "basic")
		save_file.set_value("LessonProgress", "lesson_number", 1)
		save_file.set_value("LessonProgress", "last_time", Time.get_datetime_string_from_system())
		
		save_file.save(profile_data_file)


func save_lesson_progress(lesson_number: int, difficulty: String) -> bool:
	if not save_file:
		save_file = ConfigFile.new()

	var err = save_file.load(profile_data_file)
	if err != OK:
		print("Error in _save_lesson_progress: loading data fails.")
		return false;
	
	save_file.set_value("LessonProgress", "difficulty", difficulty)
	save_file.set_value("LessonProgress", "lesson_number", lesson_number)
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
	lesson_progress['last_time'] = save_file.get_value(
		"LessonProgress", 
		"last_time", 
		Time.get_datetime_string_from_system()
	)
	return lesson_progress


func save_mistake(correct_char: String, wrong_char: String) -> bool:
	# Save string which trainee used to confused.
	if not save_file:
		save_file = ConfigFile.new()
	
	var err = save_file.load(profile_data_file)
	if err != OK:
		print("Error in save_mistake: loading save file data fails.")
		return false;
	
	# [Mistakes]
	# "correct_char"=[
	# 	{wrong_char: how_many_times, "last_time": last_time_mistake}, 
	# 	{another_w_char: how_many_times, "last_time": last_time_mistake}
	#	]
	
	var mistake_char_data : Array = save_file.get_value("Mistakes", correct_char, [] )
	
	var i := 0;
	while i < len(mistake_char_data):
		if mistake_char_data[i].has(wrong_char):
			mistake_char_data[i][wrong_char] = mistake_char_data[i][wrong_char]  + 1
			mistake_char_data[i]['last_time'] = Time.get_datetime_string_from_system()
			break
	
	if i == len(mistake_char_data):
		# Not found wrong_char, first time wrong
		mistake_char_data.append({
			wrong_char: 1,
			"last_time": Time.get_datetime_string_from_system()
		})
 
	
	save_file.set_value("Mistakes", correct_char, mistake_char_data)
	
	err = save_file.save(profile_data_file)
	if err != OK:
		print("Error in save_mistake: Saving/Updating profile data")
		return false
		
	return true


func load_mistakes() -> Array:
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
	var mistakes = []
	if not save_file:
		save_file = ConfigFile.new()

	var err = save_file.load(profile_data_file)
	if err != OK:
		print("Error in load_mistakes: loading save file data fails.")
		return [];
	
	var correct_chars = save_file.get_section_keys("Mistakes")
	for c in correct_chars:
		mistakes.append({
			c: save_file.get_value("Mistakes", c, []) 
		})
	
	return mistakes


func save_stats(accuracy: float, char_per_min: int, lesson_number: int, difficulty: String) -> bool:
	if not save_file:
		save_file = ConfigFile.new()
	
	var err = save_file.load(profile_data_file)
	if err != OK:
		print("Error in save_stats: loading save file data fails.")
		return false;
	
	save_file.set_value("Statistics", 
		str(Time.get_datetime_string_from_system()), 
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

