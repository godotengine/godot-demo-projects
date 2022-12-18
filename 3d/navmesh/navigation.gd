extends Spatial


var _cam_rotation = 0.0

onready var _camera = $CameraBase/Camera as Camera
onready var _robot = $RobotBase as Spatial


func _unhandled_input(event: InputEvent):
	if event is InputEventMouseButton and event.button_index == BUTTON_LEFT and event.pressed:
		# get closest point on navmesh for the current mouse cursor position
		var mouse_cursor_position = event.position
		var camera_ray_length = 1000.0
		var camera_ray_start = _camera.project_ray_origin(mouse_cursor_position)
		var camera_ray_end = camera_ray_start + _camera.project_ray_normal(mouse_cursor_position) * camera_ray_length
		var navigation_map = get_world().get_navigation_map()

		var closest_point_on_navmesh = NavigationServer.map_get_closest_point_to_segment(
			navigation_map,
			camera_ray_start,
			camera_ray_end
			)
		_robot.set_target_location(closest_point_on_navmesh)

	if event is InputEventMouseMotion:
		if event.button_mask & (BUTTON_MASK_MIDDLE + BUTTON_MASK_RIGHT):
			_cam_rotation += event.relative.x * 0.005
			$CameraBase.set_rotation(Vector3.UP * _cam_rotation)
			print("Camera Rotation: ", _cam_rotation)

