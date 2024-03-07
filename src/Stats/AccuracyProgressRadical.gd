extends VBoxContainer
class_name AccuracyProgressRadical

@onready var texture_progress_bar: TextureProgressBar = $TextureProgressBar

@onready var percentage_label: Label = $TextureProgressBar/PercentageLabel

var accuracy := 0.0

@export var tween_duration := 2.0
@export var perfect_100_color := Color.GREEN_YELLOW

func _ready() -> void:
	var stats : Array[StatisticEntry]= UserProfileManager.load_stats()
	texture_progress_bar.value = 0
	var stat := stats[stats.size() - 1]

	accuracy = stat.accuracy
	show_accuracy()

func show_accuracy() -> void:
	var tween := get_tree().create_tween()
	tween.set_pause_mode(Tween.TWEEN_PAUSE_PROCESS)
	tween.finished.connect(func() -> void: set_process(false))
	(
		tween
		. tween_property(texture_progress_bar, "value", accuracy, tween_duration)
		. set_trans(Tween.TRANS_SINE)
		. set_ease(Tween.EASE_OUT)
	)
#	accuracy = 80
	if accuracy == 100:
		percentage_label.modulate = perfect_100_color
	elif accuracy >= 90.0:
		percentage_label.modulate = Color(1, 1, 1, 1)


func _process(delta: float) -> void:
	# **Warning** _process will stop running when tween is finished
	percentage_label.text = ("%.2f" % texture_progress_bar.value) + " %"
