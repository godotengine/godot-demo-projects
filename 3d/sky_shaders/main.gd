extends Node3D


const MOUSE_SENSITIVITY = 0.001

# The camera field of view to smoothly interpolate to.
@onready var desired_fov: float = $YawCamera/Camera3D.fov


func _ready() -> void:
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED


func _process(delta: float) -> void:
	# Make the slider follow the day/night cycle.
	$Panel/MarginContainer/VBoxContainer/TimeOfDay/HSlider.value = $AnimationPlayer.current_animation_position
	$WorldEnvironment.environment.sky.sky_material.set_shader_parameter(&"cloud_time_offset", $AnimationPlayer.current_animation_position)

	$YawCamera/Camera3D.fov = lerpf($YawCamera/Camera3D.fov, desired_fov, 1.0 - exp(-delta * 10.0))



func _input(input_event: InputEvent) -> void:
	if input_event.is_action_pressed(&"toggle_gui"):
		$Panel.visible = not $Panel.visible
		$Help.visible = not $Help.visible

	if input_event.is_action_pressed(&"toggle_spheres"):
		$Spheres.visible = not $Spheres.visible

	if input_event.is_action_pressed(&"toggle_mouse_capture"):
		if Input.mouse_mode == Input.MOUSE_MODE_CAPTURED:
			Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
		else:
			Input.mouse_mode = Input.MOUSE_MODE_CAPTURED

	if Input.mouse_mode == Input.MOUSE_MODE_CAPTURED and input_event is InputEventMouseMotion:
		# Mouselook.
		var relative_motion: Vector2 = input_event.screen_relative
		$YawCamera.rotation.x = clampf($YawCamera.rotation.x - relative_motion.y * MOUSE_SENSITIVITY, -TAU * 0.25, TAU * 0.25)
		$YawCamera.rotation.y -= relative_motion.x * MOUSE_SENSITIVITY

	# Mouse wheel currently doesn't work in input actions. Hardcode mouse wheel as a workaround.
	if input_event.is_action_pressed(&"increase_camera_fov") or Input.is_mouse_button_pressed(MOUSE_BUTTON_WHEEL_DOWN):
		desired_fov = clampf(desired_fov + 5.0, 20.0, 120.0)
	if input_event.is_action_pressed(&"decrease_camera_fov") or Input.is_mouse_button_pressed(MOUSE_BUTTON_WHEEL_UP):
		desired_fov = clampf(desired_fov - 5.0, 20.0, 120.0)


func _on_time_of_day_value_changed(value: float) -> void:
	# Update time of day.
	$AnimationPlayer.seek(value)
	# TODO: Display HH:MM time.
	$Panel/MarginContainer/VBoxContainer/TimeOfDay/Value.text = str(value).pad_decimals(2)


func _on_speed_minus_pressed() -> void:
	# Allow minimum value to be zero so that the special case can be reached for pausing.
	$AnimationPlayer.speed_scale = clampf($AnimationPlayer.speed_scale * 0.5, 0.0, 12.8)
	if $AnimationPlayer.speed_scale < 0.0499:
		# Going below 0.5× speed; pause.
		$AnimationPlayer.speed_scale = 0.0

	update_speed_label()


func _on_speed_plus_pressed() -> void:
	$AnimationPlayer.speed_scale = clampf($AnimationPlayer.speed_scale * 2.0, 0.05, 12.8)
	if is_zero_approx($AnimationPlayer.speed_scale):
		# Currently paused; resume playback.
		$AnimationPlayer.speed_scale = 0.1

	update_speed_label()


func update_speed_label() -> void:
	# The default speed scale for this AnimationPlayer is internally 0.1, so multiply the displayed value by 10.
	if is_zero_approx($AnimationPlayer.speed_scale):
		$Panel/MarginContainer/VBoxContainer/TimeOfDay/CurrentSpeed.text = "Pause"
	else:
		$Panel/MarginContainer/VBoxContainer/TimeOfDay/CurrentSpeed.text = "%.2f×" % ($AnimationPlayer.speed_scale * 10)


func _on_cloud_coverage_value_changed(value: float) -> void:
	$WorldEnvironment.environment.sky.sky_material.set_shader_parameter(&"cloud_coverage", value)
	$Panel/MarginContainer/VBoxContainer/Clouds/CoverageValue.text = "%d%%" % (value * 100)


func _on_cloud_density_value_changed(value: float) -> void:
	$WorldEnvironment.environment.sky.sky_material.set_shader_parameter(&"cloud_density", value)
	$Panel/MarginContainer/VBoxContainer/Clouds/DensityValue.text = "%d%%" % (value * 100)


func _on_process_mode_item_selected(index: int) -> void:
	match index:
		0:
			$WorldEnvironment.environment.sky.process_mode = Sky.PROCESS_MODE_QUALITY
			$Panel/MarginContainer/VBoxContainer/RadianceSize.visible = true
			# Reset radiance size as the engine forces radiance size to 256 after switching to the Real-Time process mode.
			_on_radiance_size_item_selected($Panel/MarginContainer/VBoxContainer/RadianceSize/OptionButton.selected)
		1:
			$WorldEnvironment.environment.sky.process_mode = Sky.PROCESS_MODE_INCREMENTAL
			$Panel/MarginContainer/VBoxContainer/RadianceSize.visible = true
			# Reset radiance size as the engine forces radiance size to 256 after switching to the Real-Time process mode.
			_on_radiance_size_item_selected($Panel/MarginContainer/VBoxContainer/RadianceSize/OptionButton.selected)
		2:
			$WorldEnvironment.environment.sky.process_mode = Sky.PROCESS_MODE_REALTIME
			# Radiance size is forced to 256 by the engine when using Real-Time process mode.
			$Panel/MarginContainer/VBoxContainer/RadianceSize.visible = false


func _on_radiance_size_item_selected(index: int) -> void:
	match index:
		0:
			$WorldEnvironment.environment.sky.radiance_size = Sky.RADIANCE_SIZE_32
		1:
			$WorldEnvironment.environment.sky.radiance_size = Sky.RADIANCE_SIZE_64
		2:
			$WorldEnvironment.environment.sky.radiance_size = Sky.RADIANCE_SIZE_128
		3:
			$WorldEnvironment.environment.sky.radiance_size = Sky.RADIANCE_SIZE_256
		4:
			$WorldEnvironment.environment.sky.radiance_size = Sky.RADIANCE_SIZE_512
