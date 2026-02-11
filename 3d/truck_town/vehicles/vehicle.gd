extends VehicleBody3D

const STEER_SPEED = 1.5
const STEER_LIMIT = 0.4
const BRAKE_STRENGTH = 2.0

@export var engine_force_value := 40.0

var turbometer: Range
var turbo_animator: AnimationPlayer

var previous_speed := linear_velocity.length()
var turbo_active := false
var headlights_active := false
var _steer_target := 0.0
var is_compatibility := RenderingServer.get_current_rendering_method() == "gl_compatibility"

@onready var desired_engine_pitch: float = $EngineSound.pitch_scale


func _ready() -> void:
	assert(turbometer)
	assert(turbo_animator)


func _physics_process(delta: float) -> void:
	_steer_target = Input.get_axis(&"turn_right", &"turn_left")
	_steer_target *= STEER_LIMIT

	# Engine sound simulation (not realistic, as this car script has no notion of gear or engine RPM).
	desired_engine_pitch = 0.05 + linear_velocity.length() / (engine_force_value * 0.5)
	# Change pitch smoothly to avoid abrupt change on collision.
	$EngineSound.pitch_scale = lerpf($EngineSound.pitch_scale, desired_engine_pitch, 0.2)

	if absf(linear_velocity.length() - previous_speed) > 1.0:
		# Sudden velocity change, likely due to a collision. Play an impact sound to give audible feedback,
		# and vibrate for haptic feedback.
		$ImpactSound.play()
		Input.vibrate_handheld(100)
		for joypad in Input.get_connected_joypads():
			Input.start_joy_vibration(joypad, 0.0, 0.5, 0.1)

	var turbo_pressed := Input.is_action_pressed(&"boost")
	var new_turbo_active := turbo_pressed and turbometer.value > 0
	if new_turbo_active != turbo_active:
		turbo_animator.play(&"TURBO" if new_turbo_active else &"Idle")

	turbo_active = new_turbo_active
	if turbo_active:
		turbometer.value -= delta * 3.0
	elif not turbo_pressed:
		turbometer.value += delta

	if turbo_active:
		constant_force = global_transform.basis.z * 400.0
	else:
		constant_force = Vector3()

	# Automatically accelerate when using touch controls (reversing overrides acceleration).
	if DisplayServer.is_touchscreen_available() or Input.is_action_pressed(&"accelerate"):
		# Increase engine force at low speeds to make the initial acceleration faster.
		var speed := linear_velocity.length()
		if speed < 5.0 and not is_zero_approx(speed):
			engine_force = clampf(engine_force_value * 5.0 / speed, 0.0, 100.0)
		else:
			engine_force = engine_force_value

		if not DisplayServer.is_touchscreen_available():
			# Apply analog throttle factor for more subtle acceleration if not fully holding down the trigger.
			engine_force *= Input.get_action_strength(&"accelerate")
	else:
		engine_force = 0.0

	if Input.is_action_pressed(&"reverse"):
		# Increase engine force at low speeds to make the initial reversing faster.
		var speed := linear_velocity.length()
		if speed < 5.0 and not is_zero_approx(speed):
			engine_force = -clampf(engine_force_value * BRAKE_STRENGTH * 5.0 / speed, 0.0, 100.0)
		else:
			engine_force = -engine_force_value * BRAKE_STRENGTH

		# Apply analog brake factor for more subtle braking if not fully holding down the trigger.
		engine_force *= Input.get_action_strength(&"reverse")

	steering = move_toward(steering, _steer_target, STEER_SPEED * delta)

	previous_speed = linear_velocity.length()


func _input(input_event: InputEvent) -> void:
	if input_event.is_action_pressed(&"toggle_headlights"):
		toggle_headlights()

	if input_event.is_action_pressed(&"honk"):
		$HonkSound.play()


func toggle_headlights() -> void:
	for node: Light3D in get_tree().get_nodes_in_group(&"headlight"):
		# Consider headlights as being inactive up to this point if their energy was previously 0.
		headlights_active = is_zero_approx(node.light_energy)
		var t := get_tree().create_tween()

		if headlights_active:
			node.visible = true

		var target_energy := 2.0 if headlights_active else 0.0
		if is_compatibility:
			# Decrease light brightness to compensate for sRGB blending in Compatibility
			# (since headlights cast shadows).
			target_energy *= 0.5
		t.tween_property(
				node,
				^"light_energy",
				target_energy,
				0.2
			).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)

		# Hide light node at the end to avoid performance impact when headlights are off
		# (Godot still renders lights with `light_energy == 0.0` otherwise).
		if not headlights_active:
			t.finished.connect(func() -> void:
				node.visible = false
			)
