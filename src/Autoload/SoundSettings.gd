extends Node

signal mute_correct_beep(muted: bool)
signal mute_incorrect_beep(muted: bool)
signal unmute
signal volume

var settings_path = "user://sound_settings.cfg"

var config : ConfigFile = null

func _ready() -> void:
	# Settings Config Setup
	config = ConfigFile.new()
	var err = config.load(settings_path)
	if err != OK:
		config.save(settings_path)
	
func get_correct_beep_muted() -> bool:
	var err = config.load(settings_path)
	if err != OK:
		config.save(settings_path)
		
	return config.get_value("Settings", "MuteCorrectBeep", false)

func set_correct_beep_muted(muted: bool) -> void:
	var err = config.load(settings_path)
	if err != OK:
		config = ConfigFile.new()

	config.set_value("Settings", "MuteCorrectBeep", muted)
	config.save(settings_path)
	self.mute_correct_beep.emit(muted)


func get_incorrect_beep_muted() -> bool:
	var err = config.load(settings_path)
	if err != OK:
		config.save(settings_path)
		
	return config.get_value("Settings", "MuteIncorrectBeep", false)


func set_incorrect_beep_muted(muted: bool) -> void:
	var err = config.load(settings_path)
	if err != OK:
		config = ConfigFile.new()

	config.set_value("Settings", "MuteIncorrectBeep", muted)
	config.save(settings_path)
	self.mute_incorrect_beep.emit(muted)
