extends CanvasItem

# Set this to your desired color when the CanvasItem's base color is white.
@export var sdr_self_modulate: Color = Color.WHITE

# Set this to -1.0 to not limit the maximum linear color value.
@export_range(0, 20, 0.1, "or_less", "or_greater") var max_linear_value_limit: float = -1.0


func _process(_delta: float) -> void:
	# Adjust the brightness of color to be the brightest possible, regardless
	# of SDR or HDR output, but no brighter than max_linear_value_limit.
	var max_linear_value = get_window().get_output_max_linear_value()
	if max_linear_value_limit >= 0.0:
		max_linear_value = minf(max_linear_value, max_linear_value_limit)
	self_modulate = normalize_color(sdr_self_modulate, max_linear_value)


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
