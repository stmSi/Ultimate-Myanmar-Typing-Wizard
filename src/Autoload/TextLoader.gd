extends Node

var text_files: PackedStringArray = []
var loaded_file: FileAccess = null

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
#	load_dir_contents(GlobalHardCoded.texts_location)
#	print(load_section())
	pass # Replace with function body.


func load_dir_contents(path) -> PackedStringArray:
	text_files = []
	var dir = DirAccess.open(path)
	if dir:
		dir.list_dir_begin()
		var file_name = dir.get_next()
		while file_name != "":
			if not dir.current_is_dir():
				text_files.append(dir.get_current_dir().path_join(file_name))
			file_name = dir.get_next()
	else:
		print("An error occurred when trying to access the path.")
	return text_files

func get_sections() -> Array:
	var sections: Array = []
	
	return sections
	pass

func load_section() -> String:
	var text: String = ''
	if loaded_file == null:
		print('File Not Loaded.')
		return ''

	while not loaded_file.eof_reached():
		var new_line = loaded_file.get_line()
		if new_line == '{{next}}':
			break
		
		if new_line == '{{message}}':
			_read_message(loaded_file)

		text += new_line + ' '

	text = text.strip_edges()
	return text

func load_file(file_path: String) -> bool:
	
	# open a file at a time?
	if loaded_file and loaded_file.is_open():
		loaded_file.close()

	if not FileAccess.file_exists(file_path):
		print('File \'' + file_path + '\' does not exists.')
		return false;
	
	var file = FileAccess.open(file_path, FileAccess.READ)
	if not file:
		print('File \'' + file_path + '\' cannot read.')
		return false
	loaded_file = file
	return true

func _read_message(file: FileAccess) -> String:
	var msg = ''
	while not loaded_file.eof_reached():
		var new_line = loaded_file.get_line()
		if new_line == '{{message_end}}':
			break
		msg += new_line + "\n"

	EventBus.message_popup.emit(msg)
	return msg
