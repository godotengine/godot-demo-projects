extends Node3D


const Character = preload("res://character.gd")

var _cam_rotation := 0.0

@onready var _camera := $CameraBase/Camera3D as Camera3D
@onready var _robot := $RobotBase as Character


func _unhandled_input(input_event: InputEvent) -> void:
	if input_event is InputEventMouseButton and input_event.button_index == MOUSE_BUTTON_LEFT and input_event.pressed:
		# Get closest point on navmesh for the current mouse cursor position.
		var mouse_cursor_position: Vector2 = input_event.position
		var camera_ray_length := 1000.0
		var camera_ray_start := _camera.project_ray_origin(mouse_cursor_position)
		var camera_ray_end := camera_ray_start + _camera.project_ray_normal(mouse_cursor_position) * camera_ray_length

		var closest_point_on_navmesh := NavigationServer3D.map_get_closest_point_to_segment(
				get_world_3d().navigation_map,
				camera_ray_start,
				camera_ray_end
			)
		_robot.set_target_position(closest_point_on_navmesh)

	elif input_event is InputEventMouseMotion:
		if input_event.button_mask & (MOUSE_BUTTON_MASK_MIDDLE + MOUSE_BUTTON_MASK_RIGHT):
			_cam_rotation -= input_event.screen_relative.x * 0.005
			$CameraBase.set_rotation(Vector3.UP * _cam_rotation)
