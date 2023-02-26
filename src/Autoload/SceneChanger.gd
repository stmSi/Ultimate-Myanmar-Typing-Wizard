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
	current_scene.free()
	
	# Load the new scene.
	var s = ResourceLoader.load(path)
	
	# Instance the new scene.
	current_scene = s.instantiate()

	# Add it to the active scene, as child of root.
	get_tree().root.add_child(current_scene)

	# Optionally, to make it compatible with the SceneTree.change_scene_to_file() API.
	get_tree().current_scene = current_scene
	
	pass

func change_to_playground_scene():
	goto_scene(playground_scene)

func change_to_exercise_editor_scene():
	goto_scene(exercise_editor_scene)

