extends CharacterBody3D

const STATE_MENU = 0
const STATE_GRAB = 1

var r_pos = Vector2()
var state = STATE_MENU

var initial_viewport_height = ProjectSettings.get_setting("display/window/size/viewport_height")

@onready var camera = $Camera3D

func _process(delta):
	if state != STATE_GRAB:
		return

	var x_movement = Input.get_axis(&"move_left", &"move_right")
	var z_movement = Input.get_axis(&"move_forward", &"move_backwards")
	var dir = direction(Vector3(x_movement, 0, z_movement))
	transform.origin += dir * 10 * delta

	var d = delta * 0.1 # Scale the input, easiest to do by scaling the delta.
	rotate(Vector3.UP, d * r_pos.x) # Yaw
	camera.transform = camera.transform.rotated(Vector3.RIGHT, d * r_pos.y) # Pitch

	r_pos = Vector2.ZERO # We've dealt with all the input, so set it to zero.


func _input(event):
	if event is InputEventMouseMotion:
		# Scale mouse sensitivity according to resolution, so that effective mouse sensitivity
		# doesn't change depending on the viewport size.
		r_pos = -event.relative * (get_viewport().size.y / initial_viewport_height)

	if event.is_action("ui_cancel") and event.is_pressed() and not event.is_echo():
		if state == STATE_GRAB:
			Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
			state = STATE_MENU
		else:
			Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
			state = STATE_GRAB


func direction(vector):
	var v = camera.get_global_transform().basis * vector
	return v.normalized()


func _on_transparent_check_button_toggled(button_pressed):
	get_viewport().transparent_bg = button_pressed
	DisplayServer.window_set_flag(DisplayServer.WINDOW_FLAG_TRANSPARENT, button_pressed)
