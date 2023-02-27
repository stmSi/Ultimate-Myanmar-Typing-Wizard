extends Node

signal current_char_changed(char: String)
signal written_string_changed(str: String)

signal select_lesson(lesson: String) # should be lesson file path
signal select_next_lesson()

signal exercise_loaded(text: String)
signal correct_text(char_pos: int)

signal finished_section()
signal finished_all_sections()

signal followup_popup_pos_changed(pos: Vector2)

signal message_popup(msg: String)
signal message_popup_closed()

signal lesson_id_loaded(lesson_id: int)
