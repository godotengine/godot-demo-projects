extends ColorRect

@export var sdr_colour: Color


func _process(_delta: float) -> void:
	# Adjust the brightness of color to be the brightest possible, regardless
	# of SDR or HDR output.
	color = normalize_color(sdr_colour, get_window().get_output_max_linear_value())


func normalize_color(srgb_color, max_linear_value = 1.0):
	# Color must be linear-encoded to use math operations.
	var linear_color = srgb_color.srgb_to_linear()
	var max_rgb_value = maxf(linear_color.r, maxf(linear_color.g, linear_color.b))
	var brightness_scale = max_linear_value / max_rgb_value
	linear_color *= brightness_scale
	# Undo changes to the alpha channel, which should not be modified.
	linear_color.a = srgb_color.a
	# Convert back to nonlinear sRGB encoding, which is required for Color in
	# Godot unless stated otherwise.
	return linear_color.linear_to_srgb()
