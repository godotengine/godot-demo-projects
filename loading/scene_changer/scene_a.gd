extends Panel


func _on_goto_scene_pressed():
	# Change the scene to the one located at the given path.
	get_tree().change_scene_to_file("res://scene_b.tscn")
