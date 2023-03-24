extends Node


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
