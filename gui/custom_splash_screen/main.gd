extends Control


func _on_restart_pressed() -> void:
	OS.set_restart_on_exit(true)
	get_tree().quit()
