extends Node

const BROADCAST_PORT: int = 4477
var peer: PacketPeerUDP

### To Discover Clients

func _ready() -> void:
	peer = PacketPeerUDP.new()
	var err: int = peer.bind(BROADCAST_PORT, "0.0.0.0")
	if err != OK:
		print("Binding Port: ", BROADCAST_PORT, " Failed.")
		return
	
	peer.set_broadcast_enabled(true)
	peer.set_dest_address("255.255.255.255", 4488)


func _exit_tree() -> void:
	if peer:
		peer.close()



func _on_timer_timeout() -> void:
	peer.put_packet("Time to stop".to_ascii_buffer())
