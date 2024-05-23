extends Node

@onready var captured_image: TextureRect = $CapturedImage
@onready var capture_button: Button = $CaptureButton


func _ready() -> void:
	# Focus button for keyboard/gamepad-friendly navigation.
	capture_button.grab_focus()


func _on_capture_button_pressed() -> void:
	# Retrieve the captured image.
	var img := get_viewport().get_texture().get_image()

	# Create a texture for it.
	var tex := ImageTexture.create_from_image(img)

	# Set the texture to the captured image node.
	captured_image.set_texture(tex)

	# Colorize the button with a random color, so you can see which button belongs to which capture.
	capture_button.modulate = Color.from_hsv(randf(), randf_range(0.2, 0.8), 1.0)
