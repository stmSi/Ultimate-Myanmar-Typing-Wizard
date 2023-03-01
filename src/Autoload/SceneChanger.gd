extends Node

var playground_scene = "res://src/Playground/Playground.tscn"
var exercise_editor_scene = "res://src/ExerciseEditor/exercise_editor.tscn"

var current_scene = null

func _ready() -> void:
	var root = get_tree().root
	
	# the last child of root is always the loaded scene
	current_scene = root.get_child(root.get_child_count() - 1)

func goto_scene(path: String):
	# This function will usually be called from a signal callback
	# Deleting the current scene at this point is
	# a bad idea, because it may still be executing code.
	# This will result in a crash or unexpected behavior.

	# The solution is to defer the load to a later time, when
	# we can be sure that no code from the current scene is running:

	call_deferred("_deferred_goto_scene", path)

func _deferred_goto_scene(path: String):
	# It is now safe to remove the current scene
	var now = Time.get_ticks_usec()
	current_scene.free()
	
	# Load the new scene.
	var s = ResourceLoader.load(path)
	
	# Instance the new scene.
	current_scene = s.instantiate()

	# Add it to the active scene, as child of root.
	get_tree().root.add_child(current_scene)

	# Optionally, to make it compatible with the SceneTree.change_scene_to_file() API.
	get_tree().current_scene = current_scene
	_animate_appear()
	
	print("Time take: ", Time.get_ticks_usec() - now)
	pass

func change_to_playground_scene():
	goto_scene(playground_scene)

func change_to_exercise_editor_scene():
	goto_scene(exercise_editor_scene)


func _animate_appear():
	# Animate Panel first using "scene_change_bg" group
	# then Elements "scene_change_element"

	var scene_change_bg_modulate_colors = [] # save original color
	var scene_change_bg = get_tree().get_nodes_in_group('scene_change_bg')
	for n in scene_change_bg:
#		scene_change_bg_modulate_colors.push_back(n.modulate)
#		scene_change_bg.push_back(n)
		n.modulate.a = 0
#		n.scale = Vector2(0, 0)
		
	var scene_change_elements_modulate_colors = [] # save original color
	var scene_change_elements = get_tree().get_nodes_in_group('scene_change_element')
	for n in scene_change_elements:
#		scene_change_elements_modulate_colors.push_back(n.modulate)
#		scene_change_elements.push_back(n)
		n.modulate.a = 0

	var bg_tween = get_tree().create_tween()
	bg_tween.set_parallel(true)
	
	for n in scene_change_bg:
		bg_tween.tween_property(n, "modulate", Color.WHITE, .1)
		bg_tween.tween_property(n, "scale", Vector2(1,1), .1)
	await bg_tween.finished
	
	for n in scene_change_elements:
		bg_tween = get_tree().create_tween()
		bg_tween.tween_property(n, "modulate", Color.WHITE, .1)
		await get_tree().create_timer(0.05).timeout

	await bg_tween.finished


func _animate_disappear():
	# Animate Panel first using "scene_change_panel" group
	# then Elements "scene_change_element"
	pass
