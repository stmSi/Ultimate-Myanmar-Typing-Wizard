extends VBoxContainer
@onready var cpm_lbl: RichTextLabel = $CPM

var cpm : int

var average_cpm : int = 190
var professional_cpm : int = 360

@export var lower_average_cpm_color : Color = Color.DARK_CYAN
@export var above_average_cpm_color : Color = Color.MEDIUM_SPRING_GREEN
@export var professional_cpm_color : Color = Color.MEDIUM_PURPLE
@onready var next_target: RichTextLabel = $NextTarget

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
		cpm = stat[timestamp]['char_per_min']
	
	cpm_lbl.clear()
	next_target.clear()
	cpm_lbl.add_text("Character Per Min (CPM): ")
	
	var level = ""
	if cpm >= professional_cpm:
		cpm_lbl.push_color(professional_cpm_color)
		level = "Profession"
		next_target.visible = false
		
	elif cpm >= average_cpm:
		cpm_lbl.push_color(above_average_cpm_color)
		level = "Above Average"
		
		next_target.add_text("Next CPM GOAL: ")
		next_target.push_color(professional_cpm_color)
		next_target.add_text(str(professional_cpm) + " (Professional Level)")
		next_target.pop()
		
	elif cpm < average_cpm:
		cpm_lbl.push_color(lower_average_cpm_color)
		level = "Below Average"
		
		next_target.add_text("Next CPM GOAL: ")
		next_target.push_color(above_average_cpm_color)
		next_target.add_text(str(average_cpm) + " (Average Level)")
		next_target.pop()
		
	cpm_lbl.add_text(str(cpm) + " (" + level + ")")
	cpm_lbl.pop()
	
	
