extends Node

var resolutions_169 = [
	"3840 x 2160",
	"2560 x 1440",
	"1920 x 1080",
	"1600 x 900",
	"1366 x 768",
	"1280 x 720"
]

var resolutions_1610 = [
	"1280 x 800",
	"1440 x 900",
	"1680 x 1050",
	"1920 x 1200", 
	"2560 x 1600", 
	"3840 x 2400", 
]

var resolutions_43 = [
	"640 x 480",
	"800 x 600",
	"1024 x 768",
	"1600 x 1200"
]

var screen_size: Vector2i
var aspect_ratio: float

var resolutions = []

func _ready() -> void:
	screen_size = DisplayServer.screen_get_size()
	aspect_ratio = screen_size.x / float(screen_size.y)
	
	if aspect_ratio > 1.7:
		resolutions = resolutions_169
	elif aspect_ratio == 1.6:
		resolutions = resolutions_1610
	else:
		resolutions = resolutions_43
	
	
