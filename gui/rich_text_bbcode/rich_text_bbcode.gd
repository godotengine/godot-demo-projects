extends Control

func _on_RichTextLabel_meta_clicked(meta):
	var err = OS.shell_open(meta)
	if err == OK:
		print("Opened link '%s' successfully!" % meta)
	else:
		print("Failed opening the link '%s'!" % meta)
