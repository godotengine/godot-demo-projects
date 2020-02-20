extends Control

func _ready():
	if OS.get_name() == "HTML5":
		$VBoxContainer/Signaling.hide()


func _on_listen_toggled(button_pressed):
	if button_pressed:
		$Server.listen(int($VBoxContainer/Signaling/Port.value))
	else:
		$Server.stop()


func _on_LinkButton_pressed():
	OS.shell_open("https://github.com/godotengine/webrtc-native/releases")
