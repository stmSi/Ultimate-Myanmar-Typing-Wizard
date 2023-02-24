extends Node

var use_r_shift_ids = [
	0,1,2,3,4,5,
	13,14,15,16,17,
	26,27,28,29,30,
	37,38,39,40,41,
	]

func need_shift(char: String) -> String:
	var idx = GlobalHardCoded.mm_shift_chars.find(char)
	
	if idx == -1:
		return 'no'
	elif use_r_shift_ids.find(idx) != -1:
		return 'r_shift'
	else:
		print(idx)
		return 'l_shift'
