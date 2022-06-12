extends KinematicBody


export(bool) var _gravity_on_floor = true
export(bool) var _stop_on_slopes = false
export(bool) var _use_snap = false

var _gravity = 20.0
var _velocity = Vector3.ZERO


func _physics_process(delta):
	var snap = Vector3.DOWN * 0.2
	if is_on_floor() and _gravity_on_floor:
		_velocity += Vector3.DOWN * _gravity * delta
	else:
		_velocity += Vector3.DOWN * _gravity * delta
		snap = Vector3.ZERO

	if _use_snap:
		_velocity = move_and_slide_with_snap(_velocity, snap, Vector3.UP, _stop_on_slopes)
	else:
		_velocity = move_and_slide(_velocity, Vector3.UP, _stop_on_slopes)
