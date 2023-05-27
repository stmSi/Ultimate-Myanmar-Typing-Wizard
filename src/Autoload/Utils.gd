extends Node

func _ready() -> void:
	# Just in case.
	check_and_create_user_dir()
	pass

func check_and_create_user_dir():
	var dir = DirAccess.open(OS.get_user_data_dir())
	print("Checking User Dir: ", OS.get_user_data_dir())
	if dir == null:
		print("User Dir Not Found.")
		print("Making: ", OS.get_user_data_dir())
		dir.make_dir_recursive(OS.get_user_data_dir())

func randomize_packed_array(packed_array: PackedStringArray):
	# PackedStringArray doesn't support shuffle()
	# convert to array, shuffle, and reassign
	randomize()
	var tmp = []
	for e in packed_array:
		tmp.append(e)
	tmp.shuffle()
	packed_array = PackedStringArray(tmp)
	return packed_array
