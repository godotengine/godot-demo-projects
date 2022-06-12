extends RigidBody2D


var _picked = false
var _last_mouse_pos = Vector2.ZERO


func _ready():
	input_pickable = true


func _input(event):
	var mouse_event = event as InputEventMouseButton
	if mouse_event and not mouse_event.pressed:
		_picked = false


func _input_event(_viewport, event, _shape_idx):
	var mouse_event = event as InputEventMouseButton
	if mouse_event and mouse_event.pressed:
		_picked = true
		_last_mouse_pos = get_global_mouse_position()


func _physics_process(delta):
	if _picked:
		var mouse_pos = get_global_mouse_position()
		if mode == MODE_STATIC:
			global_position = mouse_pos
		else:
			linear_velocity = (mouse_pos - _last_mouse_pos) / delta
			_last_mouse_pos = mouse_pos
