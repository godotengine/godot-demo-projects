extends Control

@export var sun: DirectionalLight3D
@export var lightbulb_1: OmniLight3D
@export var lightbulb_2: OmniLight3D
@export var world_environment: WorldEnvironment

## Returns color from a given temperature in kelvins (6500K is nearly white).
## Valid range is [1000; 15000].
## As explained in the Filament documentation:
## https://google.github.io/filament/Filament.md.html#lighting/directlighting/lightsparameterization
##
## This is the same function as used internally by the engine when setting a
## Light3D's `light_temperature`, but converted to GDScript.
func get_color_from_temperature(p_temperature: float) -> Color:
	var t2 := p_temperature * p_temperature
	var u := (
			(0.860117757 + 1.54118254e-4 * p_temperature + 1.28641212e-7 * t2) /
			(1.0 + 8.42420235e-4 * p_temperature + 7.08145163e-7 * t2)
	)
	var v := (
			(0.317398726 + 4.22806245e-5 * p_temperature + 4.20481691e-8 * t2) /
			(1.0 - 2.89741816e-5 * p_temperature + 1.61456053e-7 * t2)
	)

	# Convert to xyY space.
	var d := 1.0 / (2.0 * u - 8.0 * v + 4.0)
	var x := 3.0 * u * d
	var y := 2.0 * v * d

	# Convert to XYZ space.
	var a := 1.0 / maxf(y, 1e-5)
	var xyz := Vector3(x * a, 1.0, (1.0 - x - y) * a)

	# Convert from XYZ to sRGB(linear).
	var linear := Vector3(
			3.2404542 * xyz.x - 1.5371385 * xyz.y - 0.4985314 * xyz.z,
			-0.9692660 * xyz.x + 1.8760108 * xyz.y + 0.0415560 * xyz.z,
			0.0556434 * xyz.x - 0.2040259 * xyz.y + 1.0572252 * xyz.z
	)
	linear /= maxf(1e-5, linear[linear.max_axis_index()])
	# Normalize, clamp, and convert to sRGB.
	return Color(linear.x, linear.y, linear.z).clamp().linear_to_srgb()


func _on_time_of_day_value_changed(value: float) -> void:
	var offset := TAU * 0.25
	sun.rotation.x = remap(value, 0, 1440, 0 + offset, TAU + offset)

	# Improve and prevent light leaks by hiding the sun if it's below the horizon.
	const EPSILON = 0.0001
	sun.visible = sun.rotation.x > TAU * 0.5 + EPSILON and sun.rotation.x < TAU - EPSILON

	$Light/TimeOfDay/Value.text = "%02d:%02d" % [value / 60, fmod(value, 60)]


func _on_sun_intensity_value_changed(value: float) -> void:
	sun.light_intensity_lux = value
	$Light/SunIntensity/Value.text = "%d lux" % value


func _on_lightbulb1_intensity_value_changed(value: float) -> void:
	lightbulb_1.light_intensity_lumens = value
	$Light/Lightbulb1Intensity/Value.text = "%d lm" % value


func _on_lightbulb1_temperature_value_changed(value: float) -> void:
	lightbulb_1.light_temperature = value
	$Light/Lightbulb1Temperature/Value.text = "%d K" % value
	$Light/Lightbulb1Temperature/Value.add_theme_color_override("font_color", get_color_from_temperature(value))


func _on_lightbulb2_intensity_value_changed(value: float) -> void:
	lightbulb_2.light_intensity_lumens = value
	$Light/Lightbulb2Intensity/Value.text = "%d lm" % value


func _on_lightbulb2_temperature_value_changed(value: float) -> void:
	lightbulb_2.light_temperature = value
	$Light/Lightbulb2Temperature/Value.text = "%d K" % value
	$Light/Lightbulb2Temperature/Value.add_theme_color_override("font_color", get_color_from_temperature(value))


func _on_focus_distance_value_changed(value: float) -> void:
	get_viewport().get_camera_3d().attributes.frustum_focus_distance = value
	$Camera/FocusDistance/Value.text = "%.1f m" % value


func _on_focal_length_value_changed(value: float) -> void:
	get_viewport().get_camera_3d().attributes.frustum_focal_length = value
	$Camera/FocalLength/Value.text = "%d mm" % value


func _on_aperture_value_changed(value: float) -> void:
	get_viewport().get_camera_3d().attributes.exposure_aperture = value
	$Camera/Aperture/Value.text = "%.1f f-stop" % value


func _on_shutter_speed_value_changed(value: float) -> void:
	get_viewport().get_camera_3d().attributes.exposure_shutter_speed = value
	$Camera/ShutterSpeed/Value.text = "1/%d" % value


func _on_sensitivity_value_changed(value: float) -> void:
	get_viewport().get_camera_3d().attributes.exposure_sensitivity = value
	$Camera/Sensitivity/Value.text = "%d ISO" % value


func _on_autoexposure_speed_value_changed(value: float) -> void:
	get_viewport().get_camera_3d().attributes.auto_exposure_speed = value
	$Camera/AutoexposureSpeed/Value.text = "%.1f" % value


func _on_sdfgi_button_toggled(button_pressed: bool) -> void:
	world_environment.environment.sdfgi_enabled = button_pressed
