extends OptionButton



func _on_item_selected(index: int) -> void:
	DisplaySettings.change_max_fps(float(get_item_text(index)))
