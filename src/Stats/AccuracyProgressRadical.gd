extends VBoxContainer

@onready var texture_progress_bar: TextureProgressBar = $TextureProgressBar

@onready var percentage_label: Label = $TextureProgressBar/PercentageLabel

var accuracy : float = 0

func _ready() -> void:
	var stats = UserProfileManager.load_stats()
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
	tween.tween_property(texture_progress_bar, "value", accuracy, 2.0).set_trans(Tween.TRANS_SINE)

	percentage_label.text = ("%.2f" % accuracy) + " %"
