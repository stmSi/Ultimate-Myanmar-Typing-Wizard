extends Node

# /home/stm/.local/share/godot/app_userdata/Ultimate Myanmar Typing Wizard/
var profile_data_file = "user://user_profile_data.cfg"
var save_file : ConfigFile
var mistakes = {
	"correct_chars": [],
	"wrong_chars": [],
	"timestamps": [],
}

func _ready() -> void:
	if not FileAccess.file_exists(profile_data_file):
		save_file = ConfigFile.new()
		# save Default data
		save_file.set_value("LessonProgress", "difficulty", "basic")
		save_file.set_value("LessonProgress", "lesson_number", 1)
		save_file.set_value("LessonProgress", "is_finished", false)
		save_file.set_value("LessonProgress", "last_time", Time.get_datetime_string_from_system())
		
		save_file.save(profile_data_file)
		
	EventBus.wrong_char_typed.connect(func(wrong_char: String, correct_char: String):
		mistakes["correct_chars"].append(correct_char)
		mistakes["wrong_chars"].append(wrong_char)
		mistakes["timestamps"].append(Time.get_datetime_string_from_system())
	)
	
	EventBus.lesson_finished.connect(func(lesson_number: int, difficulty: String):
		save_lesson_progress(lesson_number, difficulty, true)
		save_mistakes(mistakes["correct_chars"], mistakes["wrong_chars"], mistakes["timestamps"])
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


func save_mistakes(
	correct_chars: Array, 
	wrong_chars: Array, 
	timestamps: Array) -> bool:
	# Save string which trainee used to confused.
	if not save_file:
		save_file = ConfigFile.new()
	
	if len(correct_chars) != len(wrong_chars) || len(wrong_chars) != len(timestamps):
		print("Error in save_mistakes: wrong parameter lengths.")
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
		
		var mistake_char_data : Array = save_file.get_value("Mistakes", correct_char, [] )
		
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
	
		
		save_file.set_value("Mistakes", correct_char, mistake_char_data)
		i += 1
		
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

