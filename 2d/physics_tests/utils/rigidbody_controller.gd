extends RigidBody2D


var _initial_velocity = Vector2.ZERO
var _constant_velocity = Vector2.ZERO
var _velocity = Vector2.ZERO
var _on_floor = false
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
			_velocity.x = -400.0
			_keep_velocity = false
			_constant_velocity = Vector2.ZERO
	elif Input.is_action_pressed("character_right"):
		if position.x < 1024.0:
			_velocity.x = 400.0
			_keep_velocity = false
			_constant_velocity = Vector2.ZERO

	# Handle jump controls and gravity.
	if is_on_floor():
		if not _jumping and Input.is_action_just_pressed("character_jump"):
			# Start jumping.
			_jumping = true
			_velocity.y = -1000.0
		elif not _jumping:
			# Apply velocity when standing for floor detection.
			_velocity.y = 10.0
	else:
		# Apply gravity and get jump ready.
		_jumping = false
		_velocity.y += 50.0

	linear_velocity = _velocity


func _integrate_forces(state):
	_on_floor = false

	var contacts = state.get_contact_count()
	for i in contacts:
		var pos = state.get_contact_collider_position(i)
		if pos.y > position.y:
			_on_floor = true


func is_on_floor():
	return _on_floor
