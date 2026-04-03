extends ItemList

var addresses: Array[String] = []

func _ready() -> void:
	EventBus.peer_discovered.connect(self._add_peer)

func _add_peer(ip: String) -> void:
	if addresses.find(ip) == -1:
		add_item(ip)
		addresses.push_back(ip)
