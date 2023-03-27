extends Node


func convert_char(eng_char: String, use_shift = false) -> Array:  # [Success, String]
	if eng_char.begins_with("Semi"):
		if use_shift:
			return [true, "ဂ"]
		return [true, "း"]

	elif eng_char.begins_with("BackSl"):
		eng_char = "\\"
		if use_shift:
			return [true, "\\"]

	elif eng_char.begins_with("BracketL"):
		eng_char = "["

	elif eng_char.begins_with("BracketR"):
		eng_char = "]"

	elif eng_char.begins_with("Spa"):
		return [true, " "]

	elif eng_char.begins_with("Peri"):
		if use_shift:
			return [true, "။"]
		else:
			return [true, "."]

	elif eng_char.begins_with("Com"):
		if use_shift:
			return [true, "၊"]
		else:
			return [true, ","]

	var use_mm_chars = GlobalHardCoded.mm_chars
	if use_shift:
		use_mm_chars = GlobalHardCoded.mm_shift_chars

	var idx = GlobalHardCoded.eng_chars.to_upper().find(eng_char)

	if idx == -1:
		return [false, eng_char]
	return [true, use_mm_chars[idx]]


func convert_str(eng_str: String) -> String:
	var new_str = ""
	for eng_char in eng_str:
		var idx = GlobalHardCoded.eng_chars.find(eng_char)
		if idx != -1:
			new_str += GlobalHardCoded.mm_chars[idx]
			continue

		idx = GlobalHardCoded.eng_shift_chars.find(eng_char)
		if idx != -1:
			new_str += GlobalHardCoded.mm_shift_chars[idx]
			continue

		new_str += eng_char
	return new_str
