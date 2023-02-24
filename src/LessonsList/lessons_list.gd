extends Control

@onready var basic_lessons: ItemList = %BasicLessons
@onready var intermediate_lessons: ItemList = %IntermediateLessons
@onready var advance_lessons: ItemList = %AdvanceLessons


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	_populate_lessons()

func _populate_lessons() -> void:
	_populate_basic()
	_populate_intermediate()
	_populate_advance()
	

func _populate_basic() -> void:
	basic_lessons.clear()
	var text_files = TextLoader.load_dir_contents(GlobalHardCoded.basic_lessons_location)
	text_files.sort()
	
	for f in text_files:
		var a = f.rsplit('/', true, 1)[1]
		a = a.trim_suffix('.txt')
		basic_lessons.add_item(a)
		
	pass
	
func _populate_intermediate() -> void:
	pass
	
func _populate_advance() -> void:
	pass


func _on_basic_lessons_item_selected(index: int) -> void:
	pass # Replace with function body.
