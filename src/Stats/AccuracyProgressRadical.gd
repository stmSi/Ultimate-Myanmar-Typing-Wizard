extends VBoxContainer

@onready var texture_progress_bar: TextureProgressBar = $TextureProgressBar

@onready var percentage_label: Label = $TextureProgressBar/PercentageLabel

var accuracy : float = 0.0

func _ready() -> void:
	var stats = UserProfileManager.load_stats()
	texture_progress_bar.value = 0
	if stats == []:
		# default value
		stats = \
		[
			{
				"2023-03-08T14:14:43":
				{
					'accuracy': 0.0, 
					"char_per_min": 0, 
					"difficulty": "basic", 
					"lesson_number": 1
				}
			}
		]
	var stat = stats[stats.size() - 1]
	
	for timestamp in stat:
		accuracy = stat[timestamp]['accuracy']
		
	var tween := get_tree().create_tween()
	tween.finished.connect(func(): set_process(false))
	tween \
		.tween_property(texture_progress_bar, "value", accuracy, 2.0) \
		.set_trans(Tween.TRANS_SINE) \
		.set_ease(Tween.EASE_OUT)
	if accuracy == 100:
		percentage_label.modulate = Color.PALE_TURQUOISE
	elif accuracy >= 90.0:
		percentage_label.modulate = Color(1, 1, 0, 1)

func _process(delta: float) -> void:
	# **Warning** _process will stop running when tween is finished
	percentage_label.text = ("%.2f" % texture_progress_bar.value) + " %"
