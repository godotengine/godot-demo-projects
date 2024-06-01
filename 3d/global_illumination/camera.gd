extends Camera3D

const MOUSE_SENSITIVITY = 0.002
const MOVE_SPEED = 1.5

var rot := Vector3()
var velocity := Vector3()

func _ready() -> void:
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)


func _input(event: InputEvent) -> void:
	# Mouse look (only if the mouse is captured).
	if event is InputEventMouseMotion and Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED:
		# Horizontal mouse look.
		rot.y -= event.relative.x * MOUSE_SENSITIVITY
		# Vertical mouse look.
		rot.x = clamp(rot.x - event.relative.y * MOUSE_SENSITIVITY, -1.57, 1.57)
		transform.basis = Basis.from_euler(rot)

	if event.is_action_pressed("toggle_mouse_capture"):
		if Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED:
			Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
		else:
			Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)


func _process(delta: float) -> void:
	var motion := Vector3(
			Input.get_axis(&"move_left", &"move_right"),
			0,
			Input.get_axis(&"move_forward", &"move_back")
	)

	# Normalize motion to prevent diagonal movement from being
	# `sqrt(2)` times faster than straight movement.
	motion = motion.normalized()

	velocity += MOVE_SPEED * delta * (transform.basis * motion)
	velocity *= 0.85
	position += velocity
