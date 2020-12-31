extends RigidBody


const MOUSE_DELTA_COEFFICIENT = 0.01
const CAMERA_DISTANCE_COEFFICIENT = 0.2

var _picked = false
var _last_mouse_pos = Vector2.ZERO
var _mouse_pos = Vector2.ZERO


func _ready():
	input_ray_pickable = true


func _input(event):
	var mouse_event = event as InputEventMouseButton
	if mouse_event and not mouse_event.pressed:
		if mouse_event.button_index == BUTTON_LEFT:
			_picked = false

	var mouse_motion = event as InputEventMouseMotion
	if mouse_motion:
		_mouse_pos = mouse_motion.position


func _input_event(_viewport, event, _click_pos, _click_normal, _shape_idx):
	var mouse_event = event as InputEventMouseButton
	if mouse_event and mouse_event.pressed:
		if mouse_event.button_index == BUTTON_LEFT:
			_picked = true
			_mouse_pos = mouse_event.position
			_last_mouse_pos = _mouse_pos


func _physics_process(delta):
	if _picked:
		var mouse_delta = _mouse_pos - _last_mouse_pos

		var world_delta = Vector3.ZERO
		world_delta.x = mouse_delta.x * MOUSE_DELTA_COEFFICIENT
		world_delta.y = -mouse_delta.y * MOUSE_DELTA_COEFFICIENT

		var camera = get_viewport().get_camera()
		if camera:
			var camera_basis = camera.global_transform.basis
			world_delta = camera_basis * world_delta

			var camera_dist = camera.global_transform.origin.distance_to(global_transform.origin)
			world_delta *= CAMERA_DISTANCE_COEFFICIENT * camera_dist

		if mode == MODE_STATIC:
			global_transform.origin += world_delta
		else:
			linear_velocity = world_delta / delta
		_last_mouse_pos = _mouse_pos
