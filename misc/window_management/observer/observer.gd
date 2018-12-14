extends KinematicBody

# Constants
const STATE_MENU = 0
const STATE_GRAB = 1

# Member variables
var r_pos = Vector2()
var state = STATE_MENU


func direction(vector):
	var v = $Camera.get_global_transform().basis * vector
	v = v.normalized()
	return v


func _physics_process(delta):
	if (state != STATE_GRAB):
		return

	if (Input.get_mouse_mode() != Input.MOUSE_MODE_CAPTURED):
		Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

	var dir = Vector3()
	if (Input.is_action_pressed("move_forward")):
		dir += direction(Vector3(0, 0, -1))
	if (Input.is_action_pressed("move_backwards")):
		dir += direction(Vector3(0, 0, 1))
	if (Input.is_action_pressed("move_left")):
		dir += direction(Vector3(-1, 0, 0))
	if (Input.is_action_pressed("move_right")):
		dir += direction(Vector3(1, 0, 0))

	dir = dir.normalized()

	move_and_collide(dir * 10 * delta)
	var d = delta * 0.1

	# set yaw
	rotate(Vector3(0, 1, 0), d*r_pos.x)

	# set pitch
	var pitch = $Camera.get_transform().rotated(Vector3(1, 0, 0), d * r_pos.y)
	$Camera.set_transform(pitch)

	r_pos = Vector2()


func _input(event):
	if (event is InputEventMouseMotion):
		r_pos = -event.relative

	if (event.is_action("ui_cancel") and event.is_pressed() and !event.is_echo()):
		if (state == STATE_GRAB):
			Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
			state = STATE_MENU
		else:
			Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
			state = STATE_GRAB
