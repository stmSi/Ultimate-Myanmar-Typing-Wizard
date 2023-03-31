extends Node

const PORT = 4433

@onready var remote_line_edit: LineEdit = %RemoteLineEdit
@onready var playground: Playground = $Playground
@onready var network_local_ui: Control = $NetworkLocalUI

#@onready var player_scene = preload("res://src/NetworkCompetition/player.tscn")
@onready var players_container: Node = $PlayersContainer

@export var lesson_ids := []:
	set(l_ids):
		lesson_ids = l_ids
		print("starting newtork exercise")
		$Playground.start_network_exercise(l_ids)


func _ready() -> void:
	lesson_ids.clear()
	network_local_ui.show()
	playground.hide()

	multiplayer.server_relay = false
	# Automatically start the server in headless mode.
	if DisplayServer.get_name() == "headless":
		print("Automatically starting dedicated server.")
		_on_host_btn_pressed()


func _exit_tree() -> void:
	end_competition()


func _on_host_btn_pressed() -> void:
	var peer = ENetMultiplayerPeer.new()
	peer.create_server(PORT)
	if peer.get_connection_status() == MultiplayerPeer.CONNECTION_DISCONNECTED:
		OS.alert("Failed to start multiplayer server.")
	multiplayer.multiplayer_peer = peer
	
#	start_competition()


func _on_connect_btn_pressed() -> void:
	# Start as client
	var txt: String = remote_line_edit.text
	if txt == "":
		OS.alert("Need a remote to connect to.")
		return

	var peer = ENetMultiplayerPeer.new()
	var error = peer.create_client(txt, PORT)

	if error != OK:
		OS.alert("Failed to connect.")
		return

	print(peer.get_connection_status())

	if peer.get_connection_status() == MultiplayerPeer.CONNECTION_DISCONNECTED:
		OS.alert("Failed to start client.")
		return
	multiplayer.multiplayer_peer = peer
	start_competition()


func start_competition() -> void:
	network_local_ui.hide()
	playground.show()

	if not multiplayer.is_server():
		return

	multiplayer.peer_connected.connect(add_player)
	multiplayer.peer_disconnected.connect(del_player)

	prepare_exercises()
	# Spawn already connected players.
	for id in multiplayer.get_peers():
		add_player(id)

	# Spawn the local player unless this is a dedicated server export.
	if not OS.has_feature("dedicated_server"):
		add_player(1)


#	get_tree().paused = false


func end_competition():
	lesson_ids.clear()
	if not multiplayer.is_server():
		return

	multiplayer.peer_connected.disconnect(add_player)
	multiplayer.peer_disconnected.disconnect(del_player)


func prepare_exercises():
	var files: PackedStringArray = LessonAccess.get_lesson_files("extra")
	files = Utils.randomize_packed_array(files)
	var tmp_ids = []
	for f in files:
		tmp_ids.push_back(f.get_basename().get_file())
	lesson_ids = tmp_ids
	pass


func add_player(id: int):
	var player_scene = preload("res://src/NetworkCompetition/player.tscn")
	var player = player_scene.instantiate()
#	# Set player id.
	player.player_id = id
	player.name = str(id)
	player.exercise_ids = lesson_ids
	players_container.add_child(player, true)


#	await player.ready


func del_player(id: int):
	print("player removed. ", id)


func sync_exercise(s):
	pass
