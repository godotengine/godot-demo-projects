extends Camera3D
class_name AircraftCamera

@export var distance := 10.0
@export var default_pitch := -20.0

@onready var aircraft := get_parent() as Aircraft

var yaw := 0.0
var pitch := deg_to_rad(default_pitch)


func _process(_delta: float) -> void:
	if aircraft == null:
		return

	var up := aircraft.basis.y
	var right := aircraft.basis.x
	var velocity := aircraft.linear_velocity
	var direction := velocity.normalized().rotated(right, pitch).rotated(up, yaw)
	var speed := velocity.length()
	if speed < 3.0:
		direction = lerp(-aircraft.basis.z.rotated(right, pitch).rotated(up, yaw), direction, speed / 3)
	global_position = aircraft.position - direction * distance
	look_at(aircraft.position, up)
