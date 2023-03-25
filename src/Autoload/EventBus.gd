extends Node

signal current_char_changed(char: String)
signal written_string_changed(str: String)
signal wrong_char_typed(written_char: String, correct_char: String)
signal correct_char_typed(c: String)

signal select_lesson(lesson: String) # should be lesson file path
signal select_next_lesson()

signal exercise_loaded(text: String)
signal start_network_lessons(lesson_ids: Array)
signal correct_text(char_pos: int)

signal exercise_line_finished()
signal lesson_finished(lesson_number: int, difficulty: String)
signal finished_all_difficulty_lessons(difficulty: String)

signal followup_popup_pos_changed(pos: Vector2, pending_node: KeyButton)

signal message_popup(msg: String)
signal message_popup_closed()

signal lesson_id_loaded(lesson_id: int)

signal open_settings_menu()
signal settings_menu_closed()

signal keybutton_hovered(keybutton: KeyButton)
signal keybutton_unhovered(keybutton: KeyButton)


# Game Specific Events
signal game_focus_enemy(enemy: Node2D)
signal game_enemy_pos_changed(pos: Vector2, enemy: Node2D)
signal game_enemy_dead(enemy: Node2D)
signal game_enemy_hit_npc(npc: Node2D)
