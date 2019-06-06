extends Button

func _on_Button_pressed() -> void:
	if Input.is_mouse_button_pressed(BUTTON_LEFT):
		print("Left mouse button")
	if Input.is_mouse_button_pressed(BUTTON_RIGHT):
		print("Right mouse button")
