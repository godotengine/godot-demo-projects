extends Control
class_name InfoPanel

@onready var throttle := $Parameters/Throttle as Label
@onready var speed := $Parameters/Speed as Label
@onready var vertical_speed := $Parameters/VerticalSpeed as Label
@onready var altitude := $Parameters/Altitude as Label
@onready var angle_of_attack := $Parameters/AngleOfAttack as Label

var aircraft: Aircraft


func _process(_delta: float) -> void:
	if aircraft == null:
		return
	var forward := -aircraft.basis.z
	if aircraft.motor != null:
		throttle.text = str(roundi(100 * aircraft.motor.throttle)) + " %"
	speed.text = str(roundi(aircraft.linear_velocity.dot(forward) * Motor.TO_KMPH)) + " km/h"
	vertical_speed.text = str(snappedf(aircraft.linear_velocity.dot(Vector3.UP), 0.1)) + " m/s"
	altitude.text = str(snappedf(aircraft.position.y, 0.1)) + " m"
	angle_of_attack.text = str(snappedf(get_attack_angle(), 0.1))


func get_attack_angle() -> float:
	if aircraft == null or aircraft.linear_velocity.length_squared() < 2:
		return 0.0
	var wind = -(aircraft.basis.transposed() * aircraft.linear_velocity)
	return rad_to_deg(atan2(wind.y, wind.z))
