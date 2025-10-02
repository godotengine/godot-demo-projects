extends Panel

func _on_goto_scene_pressed() -> void:
	# Change the scene to the one located at the given path.
	get_tree().change_scene_to_file("res://scene_b.tscn")
