extends Control

func _ready():
	if OS.get_name() == "HTML5":
		$vbox/Signaling.hide()

func _on_listen_toggled(button_pressed):
	if button_pressed:
		$Server.listen(int($vbox/Signaling/port.value))
	else:
		$Server.stop()

func _on_LinkButton_pressed():
	OS.shell_open("https://github.com/godotengine/webrtc-native/releases")