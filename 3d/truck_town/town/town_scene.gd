extends Node3D

enum Mood {
	SUNRISE,
	DAY,
	SUNSET,
	NIGHT,
	MAX,
}

var mood := Mood.DAY: set = set_mood

# Only assigned when using the Compatibility rendering method.
# This is used to darken the sunlight to compensate for sRGB blending (without affecting sky rendering).
var compatibility_light: DirectionalLight3D


func _ready() -> void:
	if ProjectSettings.get_setting_with_override("rendering/renderer/rendering_method") == "gl_compatibility":
		# Use PCF13 shadow filtering to improve quality (Medium maps to PCF5 instead).
		RenderingServer.directional_soft_shadow_filter_set_quality(RenderingServer.SHADOW_QUALITY_SOFT_HIGH)

		# Darken the light's energy to compensate for sRGB blending (without affecting sky rendering).
		$DirectionalLight3D.sky_mode = DirectionalLight3D.SKY_MODE_SKY_ONLY
		compatibility_light = $DirectionalLight3D.duplicate()
		compatibility_light.light_energy = $DirectionalLight3D.light_energy * 0.2
		compatibility_light.sky_mode = DirectionalLight3D.SKY_MODE_LIGHT_ONLY
		add_child(compatibility_light)


func _input(event: InputEvent) -> void:
	if event.is_action_pressed(&"cycle_mood"):
		mood = wrapi(mood + 1, 0, Mood.MAX) as Mood


func set_mood(p_mood: Mood) -> void:
	mood = p_mood

	match p_mood:
		Mood.SUNRISE:
			$DirectionalLight3D.rotation_degrees = Vector3(-20, -150, -137)
			$DirectionalLight3D.light_color = Color(0.414, 0.377, 0.25)
			$DirectionalLight3D.light_energy = 4.0
			$WorldEnvironment.environment.sky.sky_material = preload("res://town/sky_morning.tres")
			$WorldEnvironment.environment.fog_light_color = Color(0.686, 0.6, 0.467)
			$ArtificialLights.visible = false
		Mood.DAY:
			$DirectionalLight3D.rotation_degrees = Vector3(-55, -120, -31)
			$DirectionalLight3D.light_color = Color.WHITE
			$DirectionalLight3D.light_energy = 1.45
			$WorldEnvironment.environment.sky.sky_material = preload("res://town/sky_day.tres")
			$WorldEnvironment.environment.fog_light_color = Color(0.62, 0.601, 0.601)
			$ArtificialLights.visible = false
		Mood.SUNSET:
			$DirectionalLight3D.rotation_degrees = Vector3(-19, -31, 62)
			$DirectionalLight3D.light_color = Color(0.488, 0.3, 0.1)
			$DirectionalLight3D.light_energy = 4.0
			$WorldEnvironment.environment.sky.sky_material = preload("res://town/sky_sunset.tres")
			$WorldEnvironment.environment.fog_light_color = Color(0.776, 0.549, 0.502)
			$ArtificialLights.visible = true
		Mood.NIGHT:
			$DirectionalLight3D.rotation_degrees = Vector3(-49, 116, -46)
			$DirectionalLight3D.light_color = Color(0.232, 0.415, 0.413)
			$DirectionalLight3D.light_energy = 0.7
			$WorldEnvironment.environment.sky.sky_material = preload("res://town/sky_night.tres")
			$WorldEnvironment.environment.fog_light_color = Color(0.2, 0.149, 0.125)
			$ArtificialLights.visible = true

	if compatibility_light:
		# Darken the light's energy to compensate for sRGB blending (without affecting sky rendering).
		compatibility_light.rotation_degrees = $DirectionalLight3D.rotation_degrees
		compatibility_light.light_color = $DirectionalLight3D.light_color
		compatibility_light.light_energy = $DirectionalLight3D.light_energy * 0.2
