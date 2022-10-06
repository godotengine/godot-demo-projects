extends Node

@onready var captured_image = $CapturedImage

func _on_CaptureButton_pressed():
	# Retrieve the captured image.
	var img = get_viewport().get_texture().get_image()

	# Create a texture for it.
	var tex = ImageTexture.create_from_image(img)

	# Set the texture to the captured image node.
	captured_image.set_texture(tex)
