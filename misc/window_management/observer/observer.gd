extends CharacterBody3D

enum State {
	MENU,
	GRAB,
}

var r_pos := Vector2()
var state := State.MENU

var initial_viewport_height := int(ProjectSettings.get_setting("display/window/size/viewport_height"))

@onready var camera: Camera3D = $Camera3D

func _process(delta: float) -> void:
	if state != State.GRAB:
		return

	var x_movement := Input.get_axis(&"move_left", &"move_right")
	var z_movement := Input.get_axis(&"move_forward", &"move_backwards")
	var dir := direction(Vector3(x_movement, 0, z_movement))
	transform.origin += dir * 10 * delta

	# Scale the input, easiest to do by scaling the delta.
	var d := delta * 0.1
	rotate(Vector3.UP, d * r_pos.x)  # Yaw
	camera.transform = camera.transform.rotated(Vector3.RIGHT, d * r_pos.y)  # Pitch

	# We've dealt with all the input, so set it to zero.
	r_pos = Vector2.ZERO


func _input(event: InputEvent) -> void:
	if event is InputEventMouseMotion:
		# Scale mouse sensitivity according to resolution, so that effective mouse sensitivity
		# doesn't change depending on the viewport size.
		r_pos = -event.relative * (get_viewport().size.y / initial_viewport_height)

	if event.is_action("ui_cancel") and event.is_pressed() and not event.is_echo():
		if state == State.GRAB:
			Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
			state = State.MENU
		else:
			Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
			state = State.GRAB


func direction(vector: Vector3) -> Vector3:
	var v := camera.get_global_transform().basis * vector
	return v.normalized()


func _on_transparent_check_button_toggled(button_pressed: bool) -> void:
	if not DisplayServer.has_feature(DisplayServer.FEATURE_WINDOW_TRANSPARENCY):
		OS.alert("Window transparency is not supported by the current display server (%s)." % DisplayServer.get_name())
		return

	get_viewport().transparent_bg = button_pressed
	DisplayServer.window_set_flag(DisplayServer.WINDOW_FLAG_TRANSPARENT, button_pressed)
