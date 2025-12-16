extends MeshInstance3D

@export_range(0, 3, 0.05, "or_less", "or_greater") var fade_time: float = 1.0

var _base_color: Color
var _animation_value: float = 0.0


func flash() -> void:
	_animation_value = 1.0


func _init() -> void:
	_base_color = (get_active_material(0) as StandardMaterial3D).albedo_color
	set_process(true)


func _process(delta: float) -> void:
	_animation_value -= delta / fade_time
	if _animation_value < 0.0:
		_animation_value = 0.0

	if _animation_value == 0.0:
		(get_active_material(0) as StandardMaterial3D).albedo_color = _base_color
	else:
		# Adjust the brightness of color to be the brightest possible, regardless
		# of SDR or HDR output, but no brighter than max_linear_value_limit.
		var max_linear_value = get_window().get_output_max_linear_value()
		# Color must be linear-encoded to use math operations.
		var linear_color = _base_color.srgb_to_linear()
		var max_rgb_value = maxf(linear_color.r, maxf(linear_color.g, linear_color.b))
		var brightness_scale = lerpf(1.0, max_linear_value / max_rgb_value, _animation_value)
		linear_color *= brightness_scale
		# Undo changes to the alpha channel, which should not be modified.
		linear_color.a = _base_color.a
		# Convert back to nonlinear sRGB encoding, which is required for Color in
		# Godot unless stated otherwise.
		(get_active_material(0) as StandardMaterial3D).albedo_color = linear_color.linear_to_srgb()
