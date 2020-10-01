extends Camera


const ROTATION_COEFF = 0.02

var _rotation_enabled = false
var _rotation_pivot


func _ready():
	call_deferred("_initialize_pivot")


func _unhandled_input(event):
	var mouse_button_event = event as InputEventMouseButton
	if mouse_button_event:
		if mouse_button_event.button_index == BUTTON_LEFT:
			_rotation_enabled = mouse_button_event.pressed
		return

	if not _rotation_enabled:
		return

	var mouse_motion_event = event as InputEventMouseMotion
	if mouse_motion_event:
		var rotation_delta = mouse_motion_event.relative.x
		_rotation_pivot.rotate(Vector3.UP, -rotation_delta * ROTATION_COEFF)


func _initialize_pivot():
	_rotation_pivot = Spatial.new()
	var camera_parent = get_parent()
	camera_parent.add_child(_rotation_pivot)
	camera_parent.remove_child(self)
	_rotation_pivot.add_child(self)
