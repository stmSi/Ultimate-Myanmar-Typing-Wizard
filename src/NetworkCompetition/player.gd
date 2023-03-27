extends Control
class_name Player

# Set by the authority, synchronized on spawn.
@export var player_id := 5:
	set(id):
		player_id = id
		# Give authority over the player input to the appropriate peer.
		%InputSynchronizer.set_multiplayer_authority(id)

# Player synchronized input.
@onready var input = %InputSynchronizer

@export var cpm: int = 0
@export var accuracy: float = 0.0
@export var mistakes: int = 0
@export var corrects: int = 0
@export var exercise_ids := []:
	set(ids):
		exercise_ids = ids
#		print(multiplayer.get_unique_id(), " start network lessons emits")
		EventBus.start_network_lessons.emit(ids)

@export var exercise_number_progress: int = 0
@onready var player_name: Label = %PlayerName


func _ready() -> void:
	if player_id == multiplayer.get_unique_id():
		hide()
	if get_multiplayer_authority() == multiplayer.get_unique_id():
		DisplayServer.window_set_title(str(player_id))
	player_name.text = str(player_id)
