extends Area2D
class_name Enemy

@export var speed = 200

var line = ""
@onready var sprite: Sprite2D = $Sprite

signal moved(pos: Vector2)


func _process(delta: float) -> void:
	global_position.x -= (speed * delta)
	self.moved.emit(global_position)


func get_size():
	return sprite.texture.get_size()


func _on_area_entered(area: Area2D) -> void:
	if area is NPC:
		EventBus.game_enemy_hit_npc.emit(area)
