extends Camera

const MOUSE_SENSITIVITY = 0.002

# The camera movement speed.
var move_speed = 0.6

# Stores where the camera is wanting to go (based on pressed keys and speed modifier).
var motion = Vector3()

# Stores the effective camera velocity.
var velocity = Vector3()

# The initial camera node rotation.
var initial_rotation = 0


func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)


func _input(event):
	# Mouse look (effective only if the mouse is captured).
	if event is InputEventMouseMotion and Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED:
		# Horizontal mouse look
		rotation.y -= event.relative.x * MOUSE_SENSITIVITY
		# Vertical mouse look
		rotation.x = clamp(rotation.x - event.relative.y * MOUSE_SENSITIVITY, deg2rad(-90), deg2rad(90))

	if event.is_action_pressed("toggle_mouse_capture"):
		if Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED:
			Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
		else:
			Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)


func _process(delta):
	motion = Vector3(
			Input.get_action_strength("move_right") - Input.get_action_strength("move_left"),
			0,
			Input.get_action_strength("move_backwards") - Input.get_action_strength("move_forwards")
	)

	# Normalize motion to prevent diagonal movement from being `sqrt(2)` times
	# faster than straight movement.
	motion = motion.normalized()

	# Speed modifier
	if Input.is_action_pressed("move_speed"):
		motion *= 2

	# Rotate the motion based on the camera angle.
	motion = motion \
		.rotated(Vector3(0, 1, 0), rotation.y - initial_rotation) \
		.rotated(Vector3(1, 0, 0), cos(rotation.y) * rotation.x) \
		.rotated(Vector3(0, 0, 1), -sin(rotation.y) * rotation.x)

	# Add motion, apply friction and velocity.
	velocity += motion * move_speed * delta
	velocity *= 0.85
	translation += velocity
