extends Node

const BROADCAST_PORT: int = 4488
var peer : PacketPeerUDP

### To Discover Clients

func _ready() -> void:
	peer = PacketPeerUDP.new()
	var err: int = peer.bind(BROADCAST_PORT, "0.0.0.0")
	if err != OK:
		print("Binding Port: ", BROADCAST_PORT, " Failed.")
		return

	set_process(true)

func _exit_tree() -> void:
	if peer:
		peer.close()


func _process(_delta: float) -> void:
	if not peer:
		return

	while peer.get_available_packet_count() > 0:
		var data: String = peer.get_packet().get_string_from_ascii()
		print(peer.get_packet_ip(), " : ", data)
		EventBus.peer_discovered.emit(peer.get_packet_ip())
