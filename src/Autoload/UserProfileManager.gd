extends Node

# /home/stm/.local/share/godot/app_userdata/Ultimate Myanmar Typing Wizard/
var profile_data_file := "user://user_profile_data.cfg"
var save_file : ConfigFile
var mistakes : Dictionary = {
	"correct_chars": [] as Array[String],
	"wrong_chars": [] as Array[String],
	"timestamps": [] as Array[String],
}

var corrected_chars : Array[String] = []
var corrected_chars_frequency := []


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
		func(correct_c: String) -> void:
			var idx := corrected_chars.find(correct_c)
			if idx == -1:
				corrected_chars.push_back(correct_c)
				corrected_chars_frequency.push_back(1)
			else:
				corrected_chars_frequency[idx] += 1
	)

	EventBus.wrong_char_typed.connect(func(wrong_char: String, correct_char: String) -> void:
		mistakes["correct_chars"].append(correct_char)
		mistakes["wrong_chars"].append(wrong_char)
		mistakes["timestamps"].append(Time.get_datetime_string_from_system())
	)

	EventBus.lesson_finished.connect(func(lesson_number: int, difficulty: String) -> void:
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

	var err := save_file.load(profile_data_file)
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


func load_lesson_progress() -> LessonProgress:
	if not save_file:
		save_file = ConfigFile.new()

	var err := save_file.load(profile_data_file)
	if err != OK:
		print("Error in _load_lesson_progress: Returning default values.")
		return LessonProgress.new(
			1, "basic", false, Time.get_datetime_string_from_system()
		)
	var lesson_number: int = save_file.get_value("LessonProgress", "lesson_number", 1)
	var difficulty: String = save_file.get_value("LessonProgress", "difficulty", "basic")
	var is_finished: bool = save_file.get_value("LessonProgress", "is_finished", false)
	var last_time: String = save_file.get_value("LessonProgress", "last_time", Time.get_datetime_string_from_system())

	return LessonProgress.new(lesson_number, difficulty, is_finished, last_time)

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

	var err := save_file.load(profile_data_file)
	if err != OK:
		print("Error in save_mistake: loading save file data fails.")
		return false;

	var i := 0
	while(i < len(correct_chars)):
		var correct_char : String = correct_chars[i]
		var wrong_char : String= wrong_chars[i]
		var timestamp : String = timestamps[i]
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


func load_mistake_details() -> Array[CharacterMistakeDetails]:
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
	var mistakes_details : Array[CharacterMistakeDetails]= []
	if not save_file:
		save_file = ConfigFile.new()

	var err := save_file.load(profile_data_file)
	if err != OK:
		print("Error in load_mistake_details: loading save file data fails.")
		return [];

	var correct_chars := save_file.get_section_keys("MistakeDetails")
	for c in correct_chars:
		var mistake_entries_for_char: Array[MistakeDetailEntry] = []
		var mistakes : Array = save_file.get_value("MistakeDetails", c, [])
		for mistake in (mistakes as Array[MistakeDetailEntry]):
			mistake_entries_for_char.append(
				MistakeDetailEntry.new(c, mistake[c], mistake["last_time"])
			)
		mistakes_details.append(CharacterMistakeDetails.new(c, mistake_entries_for_char))

	return mistakes_details


func save_correct_characters() -> bool:
	if len(corrected_chars) != len(corrected_chars_frequency):
		print("Error in save_correct_characters: incorrect parameter lengths.")
		return false

	if not save_file:
		save_file = ConfigFile.new()

	var err := save_file.load(profile_data_file)
	if err != OK:
		print("Error in save_correct_characters: loading save file data fails.")
		return false;

	var i := 0
	while(i < len(corrected_chars)):
		# [Corrects]
		# "correct_char"=total_corrected_char_freq
		# ....
		var corrected_char := corrected_chars[i]
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


func load_correct_characters() -> Array[CorrectCharacterEntry]:
	# [Corrects]
	# "correct_char"=total_corrected_char_freq
	# ....
	var corrected_chars_entries : Array[CorrectCharacterEntry] = []
	if not save_file:
		save_file = ConfigFile.new()

	var err := save_file.load(profile_data_file)
	if err != OK:
		print("Error in load_mistake_details: loading save file data fails.")
		return [];

	var chars := save_file.get_section_keys("Corrects")
	for c in chars:
		var frequency := save_file.get_value("Corrects", c, 0) as int
		var entry := CorrectCharacterEntry.new(c, frequency)
		corrected_chars_entries.append(entry)

	return corrected_chars_entries

func save_stats(accuracy: float, char_per_min: int, lesson_number: int, difficulty: String) -> bool:
	if not save_file:
		save_file = ConfigFile.new()

	var err := save_file.load(profile_data_file)
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


func load_stats() -> Array[StatisticEntry]:
	var stats : Array[StatisticEntry] = []
	if not save_file:
		save_file = ConfigFile.new()

	var err := save_file.load(profile_data_file)
	if err != OK:
		print("Error in load_stats: loading save file data fails.")
		return [StatisticEntry.new(
			Time.get_datetime_string_from_system(),
			0.0,
			0,
			"basic",
			1
		)]

	var stats_timestamps := save_file.get_section_keys("Statistics")
	for timestamp in stats_timestamps:
		var stat_dict : Dictionary = save_file.get_value("Statistics", timestamp, {})
		var stat_entry := StatisticEntry.new(
			timestamp,
			stat_dict["accuracy"],
			stat_dict["char_per_min"],
			stat_dict["difficulty"],
			stat_dict["lesson_number"]
		)
		# Now, each stat_entry includes the timestamp, so we just add the entry directly
		stats.append(stat_entry)

	return stats

func reset_progress() -> void:
	if not save_file:
		save_file = ConfigFile.new()

	var err := save_file.load(profile_data_file)
	if err != OK:
		print("Error in reset_progress: loading save file data fails.")
		return;

	save_file.erase_section("LessonProgress")
	err = save_file.save(profile_data_file)
	if err != OK:
		print("Error in reset_progress: resetting lesson progress fails.")
		return

func reset_statistics() -> void:
	if not save_file:
		save_file = ConfigFile.new()

	var err := save_file.load(profile_data_file)
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

