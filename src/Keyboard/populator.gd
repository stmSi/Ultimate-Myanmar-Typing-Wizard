extends HBoxContainer

@export var char := "`၁၂၃၄၅၆၇၈၉၀-="
@export var shift_char := "ဎဍၒဋ$%^ရ*()_+"
@export var replacing_node_name := "1234567890"

var key_button_resource := preload("res://src/Keyboard/key_button.tscn")

signal new_key_node_added(key_name: String, node: KeyButton)


func _ready() -> void:
	var place_order_idx := 0
	var populating_node : Node = null
	for child in get_children():
		if child.name == replacing_node_name:
			place_order_idx = child.get_index()
			populating_node = child
			break

	populate(place_order_idx)
	if populating_node:
		populating_node.queue_free()


func populate(place_order_idx: int) -> void:
	for i in len(char):
		var key_button : KeyButton = key_button_resource.instantiate()

		key_button.is_char_ascii = char.unicode_at(i) <= 127
		key_button.is_shift_char_ascii = shift_char.unicode_at(i) <= 127

		key_button.shift_char = shift_char[i]
		key_button.char = char[i]
		key_button.name = char[i] + shift_char[i]

		new_key_node_added.emit(char[i], key_button)
		new_key_node_added.emit(shift_char[i], key_button)

		add_child(key_button)
		move_child(key_button, place_order_idx)
		place_order_idx += 1
