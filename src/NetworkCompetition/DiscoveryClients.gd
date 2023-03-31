extends ItemList

var addresses = []

func _ready() -> void:
	EventBus.peer_discovered.connect(self._add_peer)

func _add_peer(ip: String):
	if addresses.find(ip) == -1:
		add_item(ip)
		addresses.push_back(ip)
	pass
