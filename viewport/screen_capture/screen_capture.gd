
extends Control


func _ready():
	get_node("Button").connect("pressed", self, "_on_button_pressed");


func _on_button_pressed():
	get_viewport().set_clear_mode(Viewport.CLEAR_MODE_ONLY_NEXT_FRAME)
	# Let two frames pass to make sure the screen was captured
	yield(get_tree(), "idle_frame")
	yield(get_tree(), "idle_frame")

	# Retrieve the captured image
	var img = get_viewport().get_texture().get_data()
  
	# Flip it on the y-axis (because it's flipped)
	img.flip_y()

	# Create a texture for it
	var tex = ImageTexture.new()
	tex.create_from_image(img)

	# Set it to the capture node
	get_node("capture").set_texture(tex)
