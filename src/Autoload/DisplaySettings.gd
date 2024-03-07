extends Node

var resolutions_169 : Array[String] = [
	"3840 x 2160",
	"2560 x 1440",
	"1920 x 1080",
	"1600 x 900",
	"1366 x 768",
	"1280 x 720",
]

var resolutions_1610 : Array[String] = [
	"3840 x 2400",
	"2560 x 1600",
	"1920 x 1200",
	"1680 x 1050",
	"1440 x 900",
	"1280 x 800",
]

var resolutions_43 : Array[String] = [
	"1600 x 1200",
	"1024 x 768",
	"800 x 600",
	"640 x 480",
]

var screen_size: Vector2i
var aspect_ratio: float

var resolutions : Array[String] = []
var recommended_resolution: Vector2i

var display_settings_file := "user://display_settings.cfg"
var config: ConfigFile = null

signal renderer_changed(new_renderer: String)

signal resolution_try_changing(original: Vector2i, new: Vector2i)
signal max_fps_changed(fps: int)
func _ready() -> void:
	Utils.check_and_create_user_dir()

	# Settings Config Setup
	config = ConfigFile.new()
	var err := config.load(display_settings_file)
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
		var scr_size_str := reso.split(" x ")
		var scr_size := Vector2i(int(scr_size_str[0]), int(scr_size_str[1]))
		# compare max screen size to (from big to small) available reso
		if screen_size.x >= scr_size[0] and screen_size.y >= scr_size[1]:
			recommended_resolution = scr_size
			break

	var window_mode : int = config.get_value("Settings", "WindowMode", DisplayServer.WINDOW_MODE_WINDOWED)
	DisplayServer.window_set_mode(window_mode)

	Engine.max_fps = self.get_max_fps()

func change_screen_resolution(reso: Vector2i) -> void:
	if not config:
		config = ConfigFile.new()
		var err := config.load(display_settings_file)
		if err != OK:
			print("change_max_fps: Loading display_settings failed. Skipping")

	DisplayServer.window_set_size(reso)
	ProjectSettings.set_setting("display/window/size/window_width_override", reso[0])
	ProjectSettings.set_setting("display/window/size/window_height_override", reso[1])
	self.resolution_try_changing.emit(DisplayServer.window_get_size(), reso)  # original reso  # new reso

	config.set_value("Settings", "screen_resolution", reso)
	var err := config.save(display_settings_file)

	if err != OK:
		print("change_screen_resolution: Saving display_settings failed.")
		return


func get_screen_resolution() -> Vector2i:
	if not config:
		config = ConfigFile.new()
		var err := config.load(display_settings_file)
		if err != OK:
			print("get_screen_settings: Loading display_settings failed.")
			return DisplayServer.window_get_size()

	return config.get_value("Settings", "screen_resolution", DisplayServer.window_get_size())


func change_max_fps(max_fps: int) -> void:
	if not config:
		config = ConfigFile.new()
		var err := config.load(display_settings_file)
		if err != OK:
			print("change_max_fps: Loading display_settings file failed.")

	Engine.max_fps = max_fps
	config.set_value("Settings", "max_fps", max_fps)

	var err := config.save(display_settings_file)
	if err != OK:
		print("change_max_fps: Saving display_settings file failed.")
		return

func get_max_fps() -> int:
	if not config:
		config = ConfigFile.new()
		var err := config.load(display_settings_file)
		if err != OK:
			print("get_max_fps: Loading display_settings failed.")
			return Engine.max_fps

	return config.get_value("Settings", "max_fps", Engine.max_fps)


func change_renderer(renderer: String) -> void:
	var project_override := ConfigFile.new()
	var err := project_override.load(ProjectSettings.get_setting('application/config/project_settings_override'))
	if err != OK:
		print("change_renderer: Loading override.cfg file failed.")

	project_override.set_value("rendering", "renderer/rendering_method", renderer)
	err = project_override.save(ProjectSettings.get_setting('application/config/project_settings_override'))
	if err != OK:
		print("change_renderer: Saving override.cfg file failed.")
		return

	self.renderer_changed.emit(renderer)

func get_renderer() -> String:
	return ProjectSettings.get_setting("rendering/renderer/rendering_method")


func change_window_mode(mode: DisplayServer.WindowMode) -> void:
	if not config:
		config = ConfigFile.new()
		var err := config.load(display_settings_file)
		if err != OK:
			print("change_window_mode: Loading display_settings file failed.")

	DisplayServer.window_set_mode(mode)

	config.set_value("Settings", "WindowMode", mode)

	var err := config.save(display_settings_file)
	if err != OK:
		print("change_window_mode: Saving display_settings file failed.")
		return
