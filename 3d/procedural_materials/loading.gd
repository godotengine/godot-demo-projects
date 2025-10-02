# This acts as a staging scene shown until the main scene is fully loaded.
extends Control

func _ready() -> void:
	for i in 2:
		# Wait 2 frames before starting to change to the main scene,
		# so that the loading text can be shown instead of the splash screen.
		await get_tree().process_frame

	# Do not use `preload()` to avoid incurring the loading time before the
	# loading text can be shown.
	get_tree().change_scene_to_packed(load("res://test.tscn"))
