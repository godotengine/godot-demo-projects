extends KinematicBody

const STATE_MENU = 0
const STATE_GRAB = 1

var r_pos = Vector2()
var state = STATE_MENU

onready var camera = $Camera

func _process(delta):
	if state != STATE_GRAB:
		return

	var x_movement = Input.get_action_strength("move_right") - Input.get_action_strength("move_left")
	var z_movement = Input.get_action_strength("move_backwards") - Input.get_action_strength("move_forward")
	var dir = direction(Vector3(x_movement, 0, z_movement))
	transform.origin += dir * 10 * delta

	var d = delta * 0.1 # Scale the input, easiest to do by scaling the delta.
	rotate(Vector3.UP, d * r_pos.x) # Yaw
	camera.transform = camera.transform.rotated(Vector3.RIGHT, d * r_pos.y) # Pitch

	r_pos = Vector2.ZERO # We've dealt with all the input, so set it to zero.


func _input(event):
	if event is InputEventMouseMotion:
		r_pos = -event.relative

	if event.is_action("ui_cancel") and event.is_pressed() and !event.is_echo():
		if (state == STATE_GRAB):
			Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
			state = STATE_MENU
		else:
			Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
			state = STATE_GRAB


func direction(vector):
	var v = camera.get_global_transform().basis * vector
	return v.normalized()
