extends Node
class_name PlayerAircraftController

@onready var aircraft := get_parent() as Aircraft

var aileron_key := 0.0
var elevator_key := 0.0
var rudder_key := 0.0


func _process(delta: float) -> void:
	if aircraft == null:
		return

	process_keyboard_values(delta)

	aircraft.wing.aileron_value = clampf(aileron_key + Input.get_axis("aileron_right", "aileron_left"), -1.0, 1.0)
	aircraft.elevator.flap_value = clampf(elevator_key + Input.get_axis("elevator_down", "elevator_up"), -1.0, 1.0)
	aircraft.rudder.flap_value = clampf(rudder_key + Input.get_axis("rudder_left", "rudder_right"), -1.0, 1.0)
	aircraft.brake = Input.get_action_strength("brake") * aircraft.brake_value

	aircraft.steering = deg_to_rad(-aircraft.rudder.flap_value)

	var flap_target := aircraft.flap_modes[aircraft.flap_mode] if aircraft.flap_mode < len(aircraft.flap_modes) else 0.0
	aircraft.wing.flap_value = move_toward(aircraft.wing.flap_value, clampf(flap_target, -1.0, 1.0), delta)

	if aircraft.motor != null:
		if Input.is_action_pressed("throttle_down"):
			aircraft.motor.throttle = move_toward(aircraft.motor.throttle, 0.0, delta)
		if Input.is_action_pressed("throttle_up"):
			aircraft.motor.throttle = move_toward(aircraft.motor.throttle, 1.0, delta)



func _input(event: InputEvent) -> void:
	if aircraft == null:
		return
	if event.is_action_pressed("flap_down"):
		aircraft.flap_mode = clampi(aircraft.flap_mode + 1, 0, len(aircraft.flap_modes) - 1)
	elif event.is_action_pressed("flap_up"):
		aircraft.flap_mode = clampi(aircraft.flap_mode - 1, 0, len(aircraft.flap_modes) - 1)


func process_keyboard_values(delta: float) -> void:
	var aileron_target := Input.get_axis("aileron_right_key", "aileron_left_key")
	var elevator_target := Input.get_axis("elevator_down_key", "elevator_up_key")
	var rudder_target := Input.get_axis("rudder_left_key", "rudder_right_key")
	aileron_key = move_toward(aileron_key, aileron_target, delta * _key_speed(aileron_key, aileron_target))
	elevator_key = move_toward(elevator_key, elevator_target, delta * _key_speed(elevator_key, elevator_target))
	rudder_key = move_toward(rudder_key, rudder_target, delta * _key_speed(rudder_key, rudder_target))


func _key_speed(current: float, target: float) -> float:
	if current * target < 0.0:
		return 2.0
	return 1.0 if absf(target) > 0.0 else 2.0
