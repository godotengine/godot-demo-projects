extends RigidBody2D

var _initial_velocity := Vector2.ZERO
var _constant_velocity := Vector2.ZERO
var _motion_speed := 400.0
var _gravity_force := 50.0
var _jump_force := 1000.0
var _velocity := Vector2.ZERO
var _floor_max_angle := 45.0
var _on_floor := false
var _jumping := false
var _keep_velocity := false

func _ready() -> void:
	gravity_scale = 0.0


func _physics_process(_delta: float) -> void:
	if _initial_velocity != Vector2.ZERO:
		_velocity = _initial_velocity
		_initial_velocity = Vector2.ZERO
		_keep_velocity = true
	elif _constant_velocity != Vector2.ZERO:
		_velocity = _constant_velocity
	elif not _keep_velocity:
		_velocity.x = 0.0

	# Handle horizontal controls.
	if Input.is_action_pressed(&"character_left"):
		if position.x > 0.0:
			_velocity.x = -_motion_speed
			_keep_velocity = false
			_constant_velocity = Vector2.ZERO
	elif Input.is_action_pressed(&"character_right"):
		if position.x < 1024.0:
			_velocity.x = _motion_speed
			_keep_velocity = false
			_constant_velocity = Vector2.ZERO

	# Handle jump controls and gravity.
	if is_on_floor():
		if not _jumping and Input.is_action_just_pressed(&"character_jump"):
			# Start jumping.
			_jumping = true
			_velocity.y = -_jump_force
		elif not _jumping:
			# Reset gravity.
			_velocity.y = 0.0
	else:
		_velocity.y += _gravity_force
		_jumping = false

	linear_velocity = _velocity


func _integrate_forces(state: PhysicsDirectBodyState2D) -> void:
	_on_floor = false

	var contacts := state.get_contact_count()
	for i in contacts:
		var normal := state.get_contact_local_normal(i)

		# Detect floor.
		if acos(normal.dot(Vector2.UP)) <= deg_to_rad(_floor_max_angle) + 0.01:
			_on_floor = true

		# Detect ceiling.
		if acos(normal.dot(-Vector2.UP)) <= deg_to_rad(_floor_max_angle) + 0.01:
			_jumping = false
			_velocity.y = 0.0

func is_on_floor() -> bool:
	return _on_floor
