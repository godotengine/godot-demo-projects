extends Control

func _enter_tree() -> void:
	for c in $VBoxContainer/Clients.get_children():
		# So each child gets its own separate MultiplayerAPI.
		get_tree().set_multiplayer(
				MultiplayerAPI.create_default_interface(),
				NodePath("%s/VBoxContainer/Clients/%s" % [get_path(), c.name])
		)


func _ready() -> void:
	if OS.get_name() == "Web":
		$VBoxContainer/Signaling.hide()


func _on_listen_toggled(button_pressed: bool) -> void:
	if button_pressed:
		$Server.listen(int($VBoxContainer/Signaling/Port.value))
	else:
		$Server.stop()


func _on_LinkButton_pressed() -> void:
	OS.shell_open("https://github.com/godotengine/webrtc-native/releases")
