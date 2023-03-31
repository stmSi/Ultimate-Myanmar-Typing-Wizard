extends OptionButton

func _ready() -> void:
	clear()
	
	add_item('OpenGL (Low-end)')
	set_item_metadata(0, 'gl_compatibility')
	
	add_item('Vulkan (High-end)')
	set_item_metadata(1, 'forward_plus')
	
	if DisplaySettings.get_renderer() == 'gl_compatibility':
		select(0)
	if DisplaySettings.get_renderer() == 'forward_plus':
		select(1)



func _on_item_selected(index: int) -> void:
	DisplaySettings.change_renderer(get_item_metadata(index))

