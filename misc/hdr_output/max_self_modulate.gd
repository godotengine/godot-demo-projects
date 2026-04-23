extends CanvasItem

# Set this to your desired color when the CanvasItem's base color is white.
@export var sdr_self_modulate: Color = Color.WHITE

# Set this to -1.0 to not limit the maximum color value.
@export_range(0, 20, 0.1, "or_less", "or_greater") var linear_limit: float = -1.0

# When true, linear_limit represents the maximum luminance that final color
# should have. When false, linear_limit represents the maximum color component
# value that the final color should have.
@export var use_luminance_for_limit: bool = true


func _enter_tree() -> void:
	var window: Window = get_window()
	window.output_max_linear_value_changed.connect(_on_output_max_linear_value_changed)
	_on_output_max_linear_value_changed(window.get_output_max_linear_value())


func _exit_tree() -> void:
	get_window().output_max_linear_value_changed.disconnect(_on_output_max_linear_value_changed)


func _on_output_max_linear_value_changed(output_max_linear_value: float) -> void:
	# Color must be linear-encoded to use math operations.
	var linear_color = sdr_self_modulate.srgb_to_linear()

	if linear_limit >= 0.0:
		if use_luminance_for_limit:
			# First adjust the color to be as bright as the screen can present.
			var max_rgb_value = maxf(linear_color.r, maxf(linear_color.g, linear_color.b))
			linear_color *= output_max_linear_value / max_rgb_value

			# Apply the limit.
			var original_luminance = linear_color.get_luminance()
			if original_luminance > linear_limit:
				linear_color *= linear_limit / original_luminance
		else:
			# The math for limiting based on color component values and screen
			# capabilities can be combined.
			var limited_max_linear_value = minf(output_max_linear_value, linear_limit)
			var max_rgb_value = maxf(linear_color.r, maxf(linear_color.g, linear_color.b))
			linear_color *= limited_max_linear_value / max_rgb_value
	else:
		# No limit; scale the color to be as bright as the screen can present.
		var max_rgb_value = maxf(linear_color.r, maxf(linear_color.g, linear_color.b))
		linear_color *= output_max_linear_value / max_rgb_value

	# Undo changes to the alpha channel, which should not be modified.
	linear_color.a = sdr_self_modulate.a

	# Convert back to nonlinear sRGB encoding, which is required for Color in
	# Godot unless stated otherwise.
	self_modulate = linear_color.linear_to_srgb()
