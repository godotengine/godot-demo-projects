extends Node3D

func _ready() -> void:
	if ProjectSettings.get_setting_with_override("rendering/renderer/rendering_method") == "gl_compatibility":
		# Use PCF13 shadow filtering to improve quality (Medium maps to PCF5 instead).
		RenderingServer.directional_soft_shadow_filter_set_quality(RenderingServer.SHADOW_QUALITY_SOFT_HIGH)

		# Darken the light's energy to compensate for sRGB blending (without affecting sky rendering).
		$Sun.sky_mode = DirectionalLight3D.SKY_MODE_SKY_ONLY
		var new_light: DirectionalLight3D = $Sun.duplicate()
		new_light.light_energy = 0.35
		new_light.sky_mode = DirectionalLight3D.SKY_MODE_LIGHT_ONLY
		add_child(new_light)
