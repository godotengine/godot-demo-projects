extends Node3D
class_name Motor

@export var thrust_max := 200.0
@export var max_velocity_kmph := 80.0
@export var rpm_max := 512.0

@onready var aircraft := get_parent() as Aircraft

const TO_KMPH = 3.6
const TO_RPM := 60.0 / TAU

var throttle := 1.0
var thrust := 0.0
var rpm := 0.0


func _physics_process(_delta: float) -> void:
	var forward := -aircraft.basis.z
	var velocity := aircraft.linear_velocity.dot(forward)
	var max_velocity := max_velocity_kmph / TO_KMPH
	if velocity < max_velocity:
		thrust = thrust_max
	else:
		var zero_thrust_velocity := max_velocity * 1.2
		thrust = max(0.0, lerpf(thrust_max, 0.0, (velocity - max_velocity) / (zero_thrust_velocity - max_velocity)))
	thrust *= throttle
	aircraft.apply_force(thrust * forward, global_position - aircraft.global_position)


func _process(delta: float) -> void:
	var target_rpm := rpm_max * (1.0 - (1.0 - throttle) * (1.0 - throttle))
	rpm = move_toward(rpm, target_rpm, delta * rpm_max / 3.0)
	rotation.z += rpm / TO_RPM * delta
