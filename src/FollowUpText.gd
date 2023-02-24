extends RichTextLabel

var raw_text = 'Hello World မကလာတေ'

@export var correct_color: Color = Color.GREEN
@export var error_color: Color = Color.RED

# Called when the node enters the scene tree for the first time.
func _ready():
	EventBus.assign_text.connect(self._set_raw_text)
	pass # Replace with function body.

func _set_raw_text(t: String) -> void:
	raw_text = t
	self.text = t
