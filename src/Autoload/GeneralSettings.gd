extends Node

var settings_data = {
	
}

var general_settings_path = "user://general_settings.cfg"
var config : ConfigFile = null

signal popup_helper_disabled_changed(disabled: bool)

func _ready() -> void:
	# Settings Config Setup
	config = ConfigFile.new()
	var err = config.load(general_settings_path)
	if err != OK:
		config.save(general_settings_path)
	

func get_popup_helper_disabled() -> bool:
	var err = config.load(general_settings_path)
	if err != OK:
		config.save(general_settings_path)
		
	return config.get_value("Settings", "PopupHelperDisabled", false)

func set_popup_helper_disabled(disabled: bool) -> void:
	var err = config.load(general_settings_path)
	if err != OK:
		config = ConfigFile.new()

	config.set_value("Settings", "PopupHelperDisabled", disabled)
	config.save(general_settings_path)
	self.popup_helper_disabled_changed.emit(disabled)
