extends VBoxContainer


@onready var rich_text_label: RichTextLabel = %RichTextLabel

@onready var progress_bar: ProgressBar = %ProgressBar
@onready var lessons_done: Label = $HBoxContainer/LessonsDone

#@export_enum("basic", "intermediate", "advance") var lesson_level = "basic"

var target_color: Color = Color.GREEN
var starting_color: Color = Color.DARK_SLATE_GRAY

var lessson_leve_finished := true

func _ready() -> void:
	var lesson_progress = UserProfileManager.load_lesson_progress()
	rich_text_label.clear()
	rich_text_label.push_color(Color.GREEN)
	rich_text_label.add_text(lesson_progress['difficulty'].capitalize())
	rich_text_label.pop()
	rich_text_label.add_text(" Lesson Progress:")
	
	var lesson_files := LessonAccess.get_lesson_files(lesson_progress['difficulty'])

	lessons_done.text = str(lesson_progress['lesson_number']) + "/" + str(lesson_files.size())
	if lesson_files.size() > 0:
		var target_percentage = (float(lesson_progress['lesson_number']) / lesson_files.size()) * 100.0
		_fill_percentage(target_percentage)
		pass

func _fill_percentage(percentage: int) -> void:
		var tween := get_tree().create_tween()
		tween.tween_property(progress_bar, "value", percentage, 1.0).set_trans(Tween.TRANS_SINE)
	
