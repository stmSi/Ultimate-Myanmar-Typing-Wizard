extends FollowUpTextPopup

@export var enemy: Node2D:
	get:
		return enemy
	set(value):
		visible = true
		enemy = value


func _ready() -> void:
	ori_richtext_minimum_size_x = follow_up_rich_text.custom_minimum_size.x
	EventBus.exercise_loaded.connect(self._set_raw_text)
	EventBus.written_string_changed.connect(self._on_written_string_changed)

	EventBus.game_focus_enemy.connect(self._on_game_focus_enemy)


func _on_game_focus_enemy(enemy: Node2D):
	self.enemy = enemy
	if enemy == null:
		visible = false


func _process(delta: float) -> void:
	if self.enemy:
		global_position = Vector2(
			enemy.global_position.x, enemy.global_position.y - enemy.get_size().y / 2
		)


#	if visible:
#		call_deferred("_animate_position") # Hack for first time position not working


func _animate_position():
	var pos := enemy.global_position

	# left boundry
	if enemy.global_position.x - (panel.size.x / 2) < 5:  # 5 is for some padding
		pos.x = panel.size.x / 2

	# right
	if enemy.global_position.x + (panel.size.x / 2) > get_viewport_rect().size.x:  # 5 is for some padding
		pos.x = get_viewport_rect().size.x - (panel.size.x / 2)

	var tween = get_tree().create_tween()
	tween.tween_property(self, "global_position", pos, .2).set_trans(Tween.TRANS_CUBIC)
