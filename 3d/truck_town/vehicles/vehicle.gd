extends VehicleBody3D

const STEER_SPEED = 1.5
const STEER_LIMIT = 0.4

@export var engine_force_value := 40.0

var _steer_target := 0.0

func _physics_process(delta: float):
	var fwd_mps := (linear_velocity * transform.basis).x

	_steer_target = Input.get_axis(&"turn_right", &"turn_left")
	_steer_target *= STEER_LIMIT

	if Input.is_action_pressed(&"accelerate"):
		# Increase engine force at low speeds to make the initial acceleration faster.
		var speed := linear_velocity.length()
		if speed < 5.0 and not is_zero_approx(speed):
			engine_force = clampf(engine_force_value * 5.0 / speed, 0.0, 100.0)
		else:
			engine_force = engine_force_value
	else:
		engine_force = 0.0

	if Input.is_action_pressed(&"reverse"):
		# Increase engine force at low speeds to make the initial acceleration faster.
		if fwd_mps >= -1.0:
			var speed := linear_velocity.length()
			if speed < 5.0 and not is_zero_approx(speed):
				engine_force = -clampf(engine_force_value * 5.0 / speed, 0.0, 100.0)
			else:
				engine_force = -engine_force_value
		else:
			brake = 1.0
	else:
		brake = 0.0

	steering = move_toward(steering, _steer_target, STEER_SPEED * delta)
