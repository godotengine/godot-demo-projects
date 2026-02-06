extends Node3D

enum Mood {
	SUNRISE,
	DAY,
	SUNSET,
	NIGHT,
}

@onready var controls_sheet: Control = %Controls

var mood := Mood.DAY: set = set_mood

var turn_on_lights: bool = false
var ambient_sound: Array = [
	preload("res://town/sound/mood_sunrise.ogg"),
	preload("res://town/sound/mood_day.ogg"),
	preload("res://town/sound/mood_sunset.ogg"),
	preload("res://town/sound/mood_night.ogg"),
]

# Only assigned when using the Compatibility rendering method.
# This is used to darken the sunlight to compensate for sRGB blending (without affecting sky rendering).
var compatibility_light: DirectionalLight3D


func setup(car: Node3D, back_callback: Callable, sdfgi: bool) -> void:
	# A car scene may have vehicles.
	var car_body: VehicleBody3D = car.get_child(0)

	car_body.turbometer = %Turbometer
	car_body.turbo_animator = %TurboAnimator
	%Speedometer.car_body = car_body
	%InstancePos.add_child(car)

	%Back.pressed.connect(back_callback)
	%WorldEnvironment.environment.sdfgi_enabled = sdfgi


func _ready() -> void:
	# Ensure headlights are toggled on automatically according to the initial mood.
	# The scene tree is not available at first, so we have to set the mood a second time
	# in deferred mode, which will call the setter again.
	set_deferred(&"mood", mood)
	controls_sheet.hide()

	if RenderingServer.get_current_rendering_method() == "gl_compatibility":
		# Use PCF13 shadow filtering to improve quality (Medium maps to PCF5 instead).
		RenderingServer.directional_soft_shadow_filter_set_quality(RenderingServer.SHADOW_QUALITY_SOFT_HIGH)

		# Darken the light's energy to compensate for sRGB blending (without affecting sky rendering).
		$DirectionalLight3D.sky_mode = DirectionalLight3D.SKY_MODE_SKY_ONLY
		compatibility_light = $DirectionalLight3D.duplicate()
		compatibility_light.light_energy = $DirectionalLight3D.light_energy * 0.2
		compatibility_light.sky_mode = DirectionalLight3D.SKY_MODE_LIGHT_ONLY
		add_child(compatibility_light)

		for headlight: Light3D in get_tree().get_nodes_in_group(&"headlight"):
			# Enable Reverse Cull Face to fix shadow biasing in Compatibility.
			headlight.shadow_reverse_cull_face = true


func _input(input_event: InputEvent) -> void:
	if input_event.is_action_pressed(&"cycle_mood"):
		mood = wrapi(mood + 1, 0, Mood.size()) as Mood
		$AmbientSound.play()
		for l: Node3D in $Lamps.get_children():
			l.Light.visible = turn_on_lights
	elif input_event.is_action_pressed(&"toggle_controls"):
		controls_sheet.visible = not controls_sheet.visible


func set_mood(p_mood: Mood) -> void:
	mood = p_mood
	turn_on_lights = false

	match p_mood:
		Mood.SUNRISE:
			$DirectionalLight3D.rotation_degrees = Vector3(-20, -150, -137)
			$DirectionalLight3D.light_color = Color(0.414, 0.377, 0.25)
			$DirectionalLight3D.light_energy = 4.0
			$WorldEnvironment.environment.sky.sky_material = preload("res://town/sky_morning.tres")
			$WorldEnvironment.environment.fog_light_color = Color(0.686, 0.6, 0.467)
		Mood.DAY:
			$DirectionalLight3D.rotation_degrees = Vector3(-55, -120, -31)
			$DirectionalLight3D.light_color = Color.WHITE
			$DirectionalLight3D.light_energy = 1.45
			$WorldEnvironment.environment.sky.sky_material = preload("res://town/sky_day.tres")
			$WorldEnvironment.environment.fog_light_color = Color(0.725, 0.918, 1.0)
		Mood.SUNSET:
			$DirectionalLight3D.rotation_degrees = Vector3(-19, -31, 62)
			$DirectionalLight3D.light_color = Color(0.488, 0.3, 0.1)
			$DirectionalLight3D.light_energy = 4.0
			$WorldEnvironment.environment.sky.sky_material = preload("res://town/sky_sunset.tres")
			$WorldEnvironment.environment.fog_light_color = Color(0.776, 0.549, 0.502)
			turn_on_lights = true
		Mood.NIGHT:
			$DirectionalLight3D.rotation_degrees = Vector3(-49, 116, -46)
			$DirectionalLight3D.light_color = Color(0.232, 0.415, 0.413)
			$DirectionalLight3D.light_energy = 0.7
			$WorldEnvironment.environment.sky.sky_material = preload("res://town/sky_night.tres")
			$WorldEnvironment.environment.fog_light_color = Color(0.2, 0.149, 0.125)
			turn_on_lights = true

	$AmbientSound.stream = ambient_sound[p_mood]

	if compatibility_light:
		# Darken the light's energy to compensate for sRGB blending (without affecting sky rendering).
		compatibility_light.rotation_degrees = $DirectionalLight3D.rotation_degrees
		compatibility_light.light_color = $DirectionalLight3D.light_color
		compatibility_light.light_energy = $DirectionalLight3D.light_energy * 0.2

	if is_inside_tree():
		var car := get_tree().get_nodes_in_group(&"car")[0]
		if (
				# Switch headlights on for nighttime.
				turn_on_lights and not car.headlights_active
		) or (
				# Switch headlights off for daytime.
				not turn_on_lights and car.headlights_active
		):
			get_tree().call_group(&"car", &"toggle_headlights")
