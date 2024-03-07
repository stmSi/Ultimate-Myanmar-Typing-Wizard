class_name KeyNodeMapping
extends Resource

var mapping : Dictionary = {}

func add_key_node(key_name: String, node: KeyButton) -> void:
	mapping[key_name] = node

func get_node(key_name: String) -> KeyButton:
	return mapping.get(key_name, null)

func has_key(key_name: String) -> bool:
	return mapping.has(key_name)

func reset_all_keys() -> void:
	for key in (mapping.keys() as Array[String]):
		var node := (mapping[key as String] as KeyButton)
		if node:
			node.reset_animation()
