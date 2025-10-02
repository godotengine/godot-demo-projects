extends RigidBody3D

const MOUSE_DELTA_COEFFICIENT = 0.01
const CAMERA_DISTANCE_COEFFICIENT = 0.2

var _picked := false
var _last_mouse_pos := Vector2.ZERO
var _mouse_pos := Vector2.ZERO

func _ready() -> void:
	input_ray_pickable = true


func _input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		if not event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
			_picked = false

	if event is InputEventMouseMotion:
		_mouse_pos = event.position


func _input_event(_camera: Camera3D, event: InputEvent, _position: Vector3, _normal: Vector3, _shape_idx: int) -> void:
	if event is InputEventMouseButton:
		if event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
			_picked = true
			_mouse_pos = event.position
			_last_mouse_pos = _mouse_pos


func _physics_process(delta: float) -> void:
	if _picked:
		var mouse_delta := _mouse_pos - _last_mouse_pos

		var world_delta := Vector3.ZERO
		world_delta.x = mouse_delta.x * MOUSE_DELTA_COEFFICIENT
		world_delta.y = -mouse_delta.y * MOUSE_DELTA_COEFFICIENT

		var camera := get_viewport().get_camera_3d()
		if camera:
			var camera_basis := camera.global_transform.basis
			world_delta = camera_basis * world_delta

			var camera_dist := camera.global_transform.origin.distance_to(global_transform.origin)
			const DEFAULT_CAMERA_FOV = 75.0
			var fov_coefficient := camera.fov / DEFAULT_CAMERA_FOV
			world_delta *= CAMERA_DISTANCE_COEFFICIENT * camera_dist * fov_coefficient

		if freeze:
			global_transform.origin += world_delta
		else:
			linear_velocity = world_delta / delta
		_last_mouse_pos = _mouse_pos
