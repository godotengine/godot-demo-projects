extends Control

func _on_RichTextLabel_meta_clicked(meta: Variant) -> void:
	var err := OS.shell_open(str(meta))
	if err == OK:
		print("Opened link '%s' successfully!" % str(meta))
	else:
		print("Failed opening the link '%s'!" % str(meta))


func _on_pause_toggled(button_pressed: bool) -> void:
	get_tree().paused = button_pressed
