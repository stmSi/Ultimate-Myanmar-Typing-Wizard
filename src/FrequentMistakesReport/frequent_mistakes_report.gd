extends Control
@onready var keyboard: Keyboard = %Keyboard

# I just realize array are faster than Dict :)
var mistakes_chars = []
var mistakes_chars_freq = []

# this will populate with array of dictionaries (character=frequency)
var corrects = []

@export var color_char_perfect := Color.PALE_TURQUOISE
@export var color_char_90 := Color.YELLOW
@export var color_char_50 := Color.ORANGE
@export var color_char_below := Color.RED


func _ready() -> void:
	var now = Time.get_ticks_msec()

	var mistakes = UserProfileManager.load_mistake_details()
	corrects = UserProfileManager.load_correct_characters()

	#### YEPP Algorithm :) ####
	for mistake_char_obj in mistakes:
		mistake_char_obj = mistake_char_obj as Dictionary
		var mistake_char = mistake_char_obj.keys()[0]

		var characters_mistaken_with = mistake_char_obj[mistake_char]
		var char_total_mistakes = 0
		for char_mistaken_with in characters_mistaken_with:
			char_mistaken_with.erase("last_time")
			char_total_mistakes += char_mistaken_with[char_mistaken_with.keys()[0]]

		mistakes_chars.push_back(mistake_char)
		mistakes_chars_freq.push_back(char_total_mistakes)

		var key_button: KeyButton = keyboard.key_node_mapping[mistake_char]

#		print("Character ", mistake_char, " made ", char_total_mistakes, " mistakes.")
		for correct_char in corrects:
			if correct_char.has(mistake_char):
				var without_mistakes_percentage = (
					100
					- (roundf(
						(float(char_total_mistakes) / float(correct_char[mistake_char])) * 100.0
					))
				)
#				print(
#					"Character ",
#					mistake_char,
#					" was typed ",
#					without_mistakes_percentage,
#					"% ",
#					"(",char_total_mistakes, "/", correct_char[mistake_char], ")",
#					" without mistakes.")

				if without_mistakes_percentage >= 90:
					key_button.highlight_character(mistake_char, color_char_90)
				elif without_mistakes_percentage >= 50:
					key_button.highlight_character(mistake_char, color_char_50)
				else:
					key_button.highlight_character(mistake_char, color_char_below)
				corrects.erase(correct_char)

	# Remaining will be the perfect characters
	for perfect_char in corrects:
		var key_button: KeyButton = keyboard.key_node_mapping[perfect_char.keys()[0]]
		key_button.highlight_character(perfect_char.keys()[0], color_char_perfect)

	keyboard.color_hint.set_color_hints(
		color_char_perfect, color_char_90, color_char_50, color_char_below
	)
