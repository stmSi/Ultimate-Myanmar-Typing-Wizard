extends Node2D

var text
@onready var enemy_scene := preload("res://src/MiniGames/TestGame/enemy.tscn")

@onready var game_follow_up_text_popup: Control = $GameFollowUpTextPopup
@onready var line_edit: LineEdit = $LineEdit

@onready var spawn_point: Node2D = $SpawnPoint

var sample_texts = PackedStringArray(["န်", "မ်", "တ်"])

var written_text = ''
var focused_enemy : Node2D = null

func _ready() -> void:
	randomize()
	EventBus.exercise_line_finished.connect(self._on_line_finished)
	EventBus.game_enemy_hit_npc.connect(self._on_game_enemy_hit_npc)
	_spawn_enemy()

func _on_line_finished():
	if self.focused_enemy:
		self.focused_enemy.queue_free()
		self.focused_enemy = null
		EventBus.game_focus_enemy.emit(null)
	
	if sample_texts.size() > 0:
		call_deferred("_spawn_enemy")
	else:
		EventBus.message_popup.emit("You Won!")

func _spawn_enemy():
	self.focused_enemy = enemy_scene.instantiate()
	add_child(self.focused_enemy)
	self.focused_enemy.global_position = spawn_point.global_position
	
	var idx = randi() % sample_texts.size()
	self.focused_enemy.line = sample_texts[idx]
	
	EventBus.game_focus_enemy.emit(self.focused_enemy)
	EventBus.exercise_loaded.emit(sample_texts[idx])
	
	sample_texts.remove_at(idx)

func _on_game_enemy_hit_npc(npc: Node2D):
	EventBus.message_popup.emit("He Dead.... gone forever... we lost.")
