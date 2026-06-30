extends Control

func _on_RichTextLabel_meta_clicked(meta: Variant) -> void:
	var err := OS.shell_open(str(meta))
	if err == OK:
		print("Opened link '%s' successfully!" % str(meta))
	else:
		print("Failed opening the link '%s'!" % str(meta))


func _on_pause_toggled(button_pressed: bool) -> void:
	get_tree().paused = button_pressed


func _on_print_to_console_pressed() -> void:
	print_rich($RichTextLabel.text)
	print_rich("---\n[b]Note:[/b] While the Output panel supports all BBCode tags, terminal output only supports a subset of BBCode tags. Some terminal emulators may not support all ANSI escape codes either. See the [code]print_rich()[/code] method description for details.")
