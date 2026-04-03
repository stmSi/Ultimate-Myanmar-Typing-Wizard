extends Control
@onready var keyboard: Keyboard = %Keyboard

# I just realize array are faster than Dict :)
var mistakes_chars : Array[String] = []
var mistakes_chars_freq : Array[int] = []

# this will populate with array of dictionaries (character=frequency)
var corrects : Array[CorrectCharacterEntry] = []

@export var color_char_perfect := Color.PALE_TURQUOISE
@export var color_char_90 := Color.YELLOW
@export var color_char_50 := Color.ORANGE
@export var color_char_below := Color.RED


func _ready() -> void:
	var mistakes := UserProfileManager.load_mistake_details()
	corrects = UserProfileManager.load_correct_characters()
	var corrects_by_char := {}

	for correct_entry in corrects:
		corrects_by_char[correct_entry.character] = correct_entry.frequency

	for mistake_detail in mistakes:
		var key_button: KeyButton = keyboard.key_node_mapping.get_node(mistake_detail.correct_char)
		if key_button == null:
			continue

		var correct_count := int(corrects_by_char.get(mistake_detail.correct_char, 0))
		var total_mistakes := 0
		for entry in mistake_detail.mistakes:
			total_mistakes += entry.frequency

		var total_attempts := correct_count + total_mistakes
		var accuracy_percentage := 0.0
		if total_attempts > 0:
			accuracy_percentage = (float(correct_count) / float(total_attempts)) * 100.0

		if total_mistakes == 0 and correct_count > 0:
			key_button.highlight_character(mistake_detail.correct_char, color_char_perfect)
		elif accuracy_percentage >= 90.0:
			key_button.highlight_character(mistake_detail.correct_char, color_char_90)
		elif accuracy_percentage >= 50.0:
			key_button.highlight_character(mistake_detail.correct_char, color_char_50)
		else:
			key_button.highlight_character(mistake_detail.correct_char, color_char_below)

		corrects_by_char.erase(mistake_detail.correct_char)

	# Remaining are characters with only correct inputs recorded.
	for correct_char in corrects_by_char.keys():
		var key_button: KeyButton = keyboard.key_node_mapping.get_node(correct_char)
		if key_button:
			key_button.highlight_character(correct_char, color_char_perfect)

	keyboard.color_hint.set_color_hints(
		color_char_perfect, color_char_90, color_char_50, color_char_below
	)
