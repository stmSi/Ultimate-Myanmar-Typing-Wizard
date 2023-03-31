extends Node

var BROADCAST_PORT = 4477
var peer

### To Discover Clients

func _ready() -> void:
	peer = PacketPeerUDP.new()
	var err = peer.bind(BROADCAST_PORT, "0.0.0.0")
	if err != OK:
		print("Binding Port: ", BROADCAST_PORT, " Failed.")
		return
	
	peer.set_broadcast_enabled(true)
	peer.set_dest_address("255.255.255.255", 4488)



func _on_timer_timeout() -> void:
	peer.put_packet("Time to stop".to_ascii_buffer())
