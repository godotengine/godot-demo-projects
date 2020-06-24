extends Node


func _on_OpenShellWeb_pressed():
	OS.shell_open("https://example.com")


func _on_OpenShellFolder_pressed():
	var path = OS.get_environment("HOME")
	if path == "":
		# Windows-specific.
		path = OS.get_environment("USERPROFILE")

	OS.shell_open(path)


func _on_ChangeWindowTitle_pressed():
	OS.set_window_title("Modified window title. Unicode characters for testing: é € × Ù ¨")


func _on_ChangeWindowIcon_pressed():
	var image = preload("res://icon.png").get_data()
	# Use an operation that will cause the icon to change in a visible manner.
	image.bumpmap_to_normalmap()
	OS.set_icon(image)


func _on_MoveWindowToForeground_pressed():
	OS.set_window_title("Will move window to foreground in 5 seconds, try unfocusing the window...")
	yield(get_tree().create_timer(5), "timeout")
	OS.move_window_to_foreground()
	# Restore the previous window title.
	OS.set_window_title(ProjectSettings.get_setting("application/config/name"))


func _on_RequestAttention_pressed():
	OS.set_window_title("Will request attention in 5 seconds, try unfocusing the window...")
	yield(get_tree().create_timer(5), "timeout")
	OS.request_attention()
	# Restore the previous window title.
	OS.set_window_title(ProjectSettings.get_setting("application/config/name"))


func _on_VibrateDeviceShort_pressed():
	Input.vibrate_handheld(200)


func _on_VibrateDeviceLong_pressed():
	Input.vibrate_handheld(1000)


func _on_AddGlobalMenuItems_pressed():
	OS.global_menu_add_item("Hello", "World", 0, null)
	OS.global_menu_add_separator("Hello")
	OS.global_menu_add_item("Hello2", "World2", 0, null)


func _on_RemoveGlobalMenuItem_pressed():
	OS.global_menu_remove_item("Hello", 0)


func _on_GetClipboard_pressed():
	OS.alert("Clipboard contents:\n\n%s" % OS.clipboard)


func _on_SetClipboard_pressed():
	OS.clipboard = "Modified clipboard contents. Unicode characters for testing: é € × Ù ¨"


func _on_DisplayAlert_pressed():
	OS.alert("Hello from Godot! Close this dialog to resume the main window.")


func _on_KillCurrentProcess_pressed():
	OS.kill(OS.get_process_id())
