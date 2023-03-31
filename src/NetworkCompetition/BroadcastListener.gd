extends Node

var BROADCAST_PORT = 4488
var peer : PacketPeerUDP
var thread = null

### To Discover Clients

func _ready() -> void:
	peer = PacketPeerUDP.new()
	var err = peer.bind(BROADCAST_PORT, "0.0.0.0")
	if err != OK:
		print("Binding Port: ", BROADCAST_PORT, " Failed.")
		return
	
	thread = Thread.new()
	thread.start(discover_peers)



func discover_peers() -> void:
	while peer.wait() == OK:
		var data = peer.get_packet().get_string_from_ascii()
		print(peer.get_packet_ip(), " : ", data)
		EventBus.peer_discovered.emit(peer.get_packet_ip())
