extends Node
# Changing scenes is most easily done using the functions change_scene_to_file
# and change_scene_to_packed of the SceneTree. This script demonstrates how to
# change scenes without those helpers.


func goto_scene(path: String):
	# This function will usually be called from a signal callback,
	# or some other function from the running scene.
	# Deleting the current scene at this point might be
	# a bad idea, because it may be inside of a callback or function of it.
	# The worst case will be a crash or unexpected behavior.

	# The way around this is deferring the load to a later time, when
	# it is ensured that no code from the current scene is running:
	_deferred_goto_scene.call_deferred(path)


func _deferred_goto_scene(path: String):
	# Immediately free the current scene. There is no risk here because the
	# call to this method is already deferred.
	get_tree().current_scene.free()

	var packed_scene := ResourceLoader.load(path) as PackedScene

	var instanced_scene := packed_scene.instantiate()

	# Add it to the scene tree, as direct child of root
	get_tree().root.add_child(instanced_scene)

	# Set it as the current scene, only after it has been added to the tree
	get_tree().current_scene = instanced_scene
