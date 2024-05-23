extends LinkButton

func _on_LinkButton_pressed() -> void:
	OS.shell_open("https://github.com/godotengine/webrtc-native/releases")
