extends Node

const PORT = 4433

@onready var remote_line_edit: LineEdit = %RemoteLineEdit
@onready var playground: Playground = $Playground
@onready var network_local_ui: Control = $NetworkLocalUI

#@onready var player_scene = preload("res://src/NetworkCompetition/player.tscn")
@onready var players_container: Node = $PlayersContainer

func _ready() -> void:
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

	start_competition()


func _on_connect_btn_pressed() -> void:
	# Start as client
	var txt: String = remote_line_edit.text
	if txt == '':
		OS.alert("Need a remote to connect to.")
		return
	
	var peer = ENetMultiplayerPeer.new()
	peer.create_client(txt, PORT)
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
		
	print('Server!!')
	multiplayer.peer_connected.connect(add_player)
	multiplayer.peer_disconnected.connect(del_player)
	# Spawn already connected players.
	for id in multiplayer.get_peers():
		add_player(id)

	# Spawn the local player unless this is a dedicated server export.
	if not OS.has_feature("dedicated_server"):
		add_player(1)

#	get_tree().paused = false

func end_competition():
	if not multiplayer.is_server():
		return
		
	multiplayer.peer_connected.disconnect(add_player)
	multiplayer.peer_disconnected.disconnect(del_player)


func add_player(id: int):
	var player_scene = preload("res://src/NetworkCompetition/player.tscn")
	var player = player_scene.instantiate()
#	# Set player id.
	player.player_id = id
	player.name = str(id)
#	# Randomize character position.
#	var pos := Vector2.from_angle(randf() * 2 * PI)
#	character.position = Vector3(pos.x * SPAWN_RANDOM * randf(), 0, pos.y * SPAWN_RANDOM * randf())
#	character.name = str(id)
#	$Players.add_child(character, true)
	players_container.add_child(player, true)
	pass


func del_player(id: int):
	print('player removed. ', id)
