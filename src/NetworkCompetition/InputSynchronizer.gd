extends MultiplayerSynchronizer
@onready var follow_up_rich_text: RichTextLabel = %FollowUpRichText

func _ready() -> void:
	
	set_process_input(get_multiplayer_authority() == multiplayer.get_unique_id())

func _input(event: InputEvent) -> void:
	
	if event is InputEventKey and event.is_pressed():
		follow_up_rich_text.text = event.as_text_physical_keycode()
