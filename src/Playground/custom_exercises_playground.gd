extends Control
@onready var playground: Playground = $Playground

@export var exercises: PackedStringArray = []

func _ready() -> void:
	playground.start_custom_exercises(SceneChanger.custom_exercises)
