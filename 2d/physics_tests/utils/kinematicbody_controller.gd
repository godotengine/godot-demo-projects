extends KinematicBody2D


var _initial_velocity = Vector2.ZERO
var _constant_velocity = Vector2.ZERO
var _motion_speed = 400.0
var _gravity_force = 50.0
var _jump_force = 1000.0
var _velocity = Vector2.ZERO
var _snap = Vector2.ZERO
var _floor_max_angle = 45.0
var _stop_on_slope = false
var _jumping = false
var _keep_velocity = false


func _physics_process(_delta):
	if _initial_velocity != Vector2.ZERO:
		_velocity = _initial_velocity
		_initial_velocity = Vector2.ZERO
		_keep_velocity = true
	elif _constant_velocity != Vector2.ZERO:
		_velocity = _constant_velocity
	elif not _keep_velocity:
		_velocity.x = 0.0

	# Handle horizontal controls.
	if Input.is_action_pressed("character_left"):
		if position.x > 0.0:
			_velocity.x = -_motion_speed
			_keep_velocity = false
			_constant_velocity = Vector2.ZERO
	elif Input.is_action_pressed("character_right"):
		if position.x < 1024.0:
			_velocity.x = _motion_speed
			_keep_velocity = false
			_constant_velocity = Vector2.ZERO

	# Handle jump controls and gravity.
	if is_on_floor():
		if not _jumping and Input.is_action_just_pressed("character_jump"):
			# Start jumping.
			_jumping = true
			_velocity.y = -_jump_force

	# Always apply gravity for floor detection.
	_velocity.y += _gravity_force

	var snap = _snap if not _jumping else Vector2.ZERO
	var max_angle = deg2rad(_floor_max_angle)
	_velocity = move_and_slide_with_snap(_velocity, snap, Vector2.UP, _stop_on_slope, 4, max_angle)

	# Get next jump ready.
	if _jumping:
		_jumping = false
