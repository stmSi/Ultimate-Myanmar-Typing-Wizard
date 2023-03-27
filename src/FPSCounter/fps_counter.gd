extends Control
@onready var label: Label = $Label


func _process(_delta: float) -> void:
	label.text = "FPS: " + str(Performance.get_monitor(Performance.TIME_FPS))
