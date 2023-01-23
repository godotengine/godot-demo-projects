extends LinkButton


func _on_LinkButton_pressed():
	var _error = OS.shell_open("https://github.com/godotengine/webrtc-native/releases")
