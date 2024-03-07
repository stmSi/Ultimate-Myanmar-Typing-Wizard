extends OptionButton

func _ready() -> void:
	_on_max_fps_changed(DisplaySettings.get_max_fps())

	DisplaySettings.max_fps_changed.connect(self._on_max_fps_changed)

func _on_item_selected(index: int) -> void:
	var txt := get_item_text(index)
	DisplaySettings.change_max_fps(int(txt))


func _on_max_fps_changed(fps: int) -> void:
	for i in self.item_count:
		if fps == int(self.get_item_text(i)):
			self.selected = i

