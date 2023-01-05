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
	DisplayServer.window_set_title("Modified window title. Unicode characters for testing: é € × Ù ¨")


func _on_ChangeWindowIcon_pressed():
	var image = Image.create(128, 128, false, Image.FORMAT_RGB8)
	image.fill(Color(1, 0.6, 0.3))
	DisplayServer.set_icon(image)


func _on_MoveWindowToForeground_pressed():
	DisplayServer.window_set_title("Will move window to foreground in 5 seconds, try unfocusing the window...")
	await get_tree().create_timer(5).timeout
	DisplayServer.window_move_to_foreground()
	# Restore the previous window title.
	DisplayServer.window_set_title(ProjectSettings.get_setting("application/config/name"))


func _on_RequestAttention_pressed():
	DisplayServer.window_set_title("Will request attention in 5 seconds, try unfocusing the window...")
	await get_tree().create_timer(5).timeout
	DisplayServer.window_request_attention()
	# Restore the previous window title.
	DisplayServer.window_set_title(ProjectSettings.get_setting("application/config/name"))


func _on_VibrateDeviceShort_pressed():
	Input.vibrate_handheld(200)


func _on_VibrateDeviceLong_pressed():
	Input.vibrate_handheld(1000)


func _on_AddGlobalMenuItems_pressed():
	DisplayServer.global_menu_add_item("Hello", "World", func(): print("Clicked"), func(): print("Clicked Key"))
	DisplayServer.global_menu_add_separator("Example Separator")
	DisplayServer.global_menu_add_item("Hello2", "World2", func(): print("Clicked 2"), func(): print("Clicked Key 2"))


func _on_RemoveGlobalMenuItem_pressed():
	DisplayServer.global_menu_remove_item("Hello", 0)


func _on_GetClipboard_pressed():
	OS.alert("Clipboard contents:\n\n%s" % DisplayServer.clipboard_get())


func _on_SetClipboard_pressed():
	DisplayServer.clipboard_set("Modified clipboard contents. Unicode characters for testing: é € × Ù ¨")


func _on_DisplayAlert_pressed():
	OS.alert("Hello from Godot! Close this dialog to resume the main window.")


func _on_KillCurrentProcess_pressed():
	OS.kill(OS.get_process_id())
