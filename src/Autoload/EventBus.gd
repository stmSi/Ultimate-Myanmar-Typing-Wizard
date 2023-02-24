extends Node

signal current_char_changed(char: String)
signal written_string_changed(str: String)

signal select_lesson(lesson: String) # should be lesson file path
signal select_next_lesson()

signal assign_text(text: String)
signal correct_text(char_pos: int)

signal finished_section()
signal finished_all_sections()
