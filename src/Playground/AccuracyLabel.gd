extends Label
class_name AccuracyLabel

var num_corrects := 0.0
var num_wrongs := 0.0
var percentage = 100
var accuracy_color: Color

@export var color_100: Color = Color.GREEN
@export var color_0: Color = Color.RED

func _ready() -> void:
	EventBus.wrong_char_typed.connect(
		func(c: String): 
			num_wrongs += 1
			_calculate_show()
	)
	
	EventBus.correct_char_typed.connect(
		func(_c: String):
			num_corrects += 1
			_calculate_show()
	)
	
	EventBus.finished_all_difficulty_lessons.connect(
		func():
			num_corrects = 0.0
			num_wrongs = 0.0
			_calculate_show()
	)

func _calculate_show():
	var total = num_corrects + num_wrongs
	if total == 0:
		self.text = "100 %" # Division by 0 error
	else:
		percentage = (num_corrects / total) * 100
	
#	label_settings.font_color = color
	accuracy_color = get_accuracy_color()
	label_settings.shadow_color = accuracy_color
	label_settings.outline_color = accuracy_color
	self.text = "%.2f" % percentage
	self.text += "% "


func get_accuracy_color() -> Color:
	var color: Color = lerp(color_0, color_100, percentage/100.0)
	if percentage < 90:
		# more red below 90
		color.r += 0.3
		color.g -= 0.2
	
	return color

func get_accuracy_color_hex() -> String:
	return "#%02x%02x%02x%02x" % [
		accuracy_color.r8, 
		accuracy_color.g8, 
		accuracy_color.b8, 
		accuracy_color.a8
	]
