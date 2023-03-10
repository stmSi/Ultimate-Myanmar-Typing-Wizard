extends Node

var resolutions_169 = [
	"3840 x 2160",
	"2560 x 1440",
	"1920 x 1080",
	"1600 x 900",
	"1366 x 768",
	"1280 x 720",
]

var resolutions_1610 = [
	"3840 x 2400", 
	"2560 x 1600", 
	"1920 x 1200", 
	"1680 x 1050",
	"1440 x 900",
	"1280 x 800",
]

var resolutions_43 = [
	"1600 x 1200",
	"1024 x 768",
	"800 x 600",
	"640 x 480",
]

var screen_size: Vector2i
var aspect_ratio: float

var resolutions = []
var recommended_resolution: Vector2i
var settings_data = {
	
}

var display_settings_file = "user://display_settings.cfg"
var config : ConfigFile = null

signal resolution_try_changing(original: Vector2i, new: Vector2i)


func _ready() -> void:
	# Settings Config Setup
	config = ConfigFile.new()
	var err = config.load(display_settings_file)
	if err != OK:
		config.save(display_settings_file)
		
	screen_size = DisplayServer.screen_get_size()
	aspect_ratio = screen_size.x / float(screen_size.y)
	
	if aspect_ratio > 1.7:
		resolutions = resolutions_169
	elif aspect_ratio == 1.6:
		resolutions = resolutions_1610
	else:
		resolutions = resolutions_43
	
	for reso in resolutions:
		var scr_size_str = reso.split(" x ")
		var scr_size := Vector2i(int(scr_size_str[0]), int(scr_size_str[1]))
		# compare max screen size to (from big to small) available reso
		if screen_size.x >= scr_size[0] and screen_size.y >= scr_size[1]:
			recommended_resolution = scr_size
			break

	
func change_screen_resolution(reso: Vector2i) -> void:
	if not config:
		config = ConfigFile.new()
		var err = config.load(display_settings_file)
		if err != OK:
			print("change_max_fps: Loading display_settings failed. Skipping")

	DisplayServer.window_set_size(reso)
	ProjectSettings.set_setting("display/window/size/window_width_override", reso[0])
	ProjectSettings.set_setting("display/window/size/window_height_override", reso[1])
	self.resolution_try_changing.emit(
		DisplayServer.window_get_size(), # original reso
		reso # new reso
	)
	
	config.set_value("Settings", 'screen_resolution', reso)
	var err = config.save(display_settings_file)
	
	if err != OK:
		print("change_screen_resolution: Saving display_settings failed.")
		return


func get_screen_resolution() -> Vector2i:
	if not config:
		config = ConfigFile.new()
		var err = config.load(display_settings_file)
		if err != OK:
			print("get_screen_settings: Loading display_settings failed.")
			return DisplayServer.window_get_size()
	
	return config.get_value("Settings", 'screen_resolution', DisplayServer.window_get_size())


func change_max_fps(max_fps: int) -> void:
	if not config:
		config = ConfigFile.new()
		var err = config.load(display_settings_file)
		if err != OK:
			print("change_max_fps: Loading display_settings file failed.")

	Engine.max_fps = max_fps
	config.set_value("Settings", 'max_fps', max_fps)
	
	var err = config.save(display_settings_file)
	if err != OK:
		print("change_max_fps: Saving display_settings file failed.")
		return
		
	
