extends Node3D

const SPEED := 10.0

@export var show_path := true

var cam_rotation := 0.0
var path: PackedVector3Array

@onready var robot: Marker3D = $RobotBase
@onready var camera: Camera3D = $CameraBase/Camera3D

func _ready():
	set_process_input(true)


func _physics_process(delta: float):
	var direction := Vector3()

	# We need to scale the movement speed by how much delta has passed,
	# otherwise the motion won't be smooth.
	var step_size := delta * SPEED

	if not path.is_empty():
		# Direction is the difference between where we are now
		# and where we want to go.
		var destination := path[0]
		direction = destination - robot.position

		# If the next node is closer than we intend to 'step', then
		# take a smaller step. Otherwise we would go past it and
		# potentially go through a wall or over a cliff edge!
		if step_size > direction.length():
			step_size = direction.length()
			# We should also remove this node since we're about to reach it.
			path.remove_at(0)

		# Move the robot towards the path node, by how far we want to travel.
		# TODO: This information should be set to the CharacterBody properties instead of arguments.
		# Note: For a CharacterBody3D, we would instead use move_and_slide
		# so collisions work properly.
		robot.position += direction.normalized() * step_size

		# Lastly let's make sure we're looking in the direction we're traveling.
		# Clamp y to 0 so the robot only looks left and right, not up/down.
		direction.y = 0
		if direction:
			# Direction is relative, so apply it to the robot's location to
			# get a point we can actually look at.
			var look_at_point := robot.position + direction.normalized()
			# Make the robot look at the point.
			robot.look_at(look_at_point, Vector3.UP)


func _unhandled_input(event: InputEvent):
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
		var map := get_world_3d().navigation_map
		var from := camera.project_ray_origin(event.position)
		var to := from + camera.project_ray_normal(event.position) * 1000
		var target_point := NavigationServer3D.map_get_closest_point_to_segment(map, from, to)

		# Set the path between the robot's current location and our target.
		path = NavigationServer3D.map_get_path(map, robot.position, target_point, true)

		if show_path:
			draw_path(path)

	elif event is InputEventMouseMotion:
		if event.button_mask & (MOUSE_BUTTON_MASK_MIDDLE + MOUSE_BUTTON_MASK_RIGHT):
			cam_rotation += event.relative.x * 0.005
			$CameraBase.set_rotation(Vector3(0, cam_rotation, 0))


func draw_path(path_array: PackedVector3Array) -> void:
	var im: ImmediateMesh = $DrawPath.mesh
	im.clear_surfaces()
	im.surface_begin(Mesh.PRIMITIVE_POINTS, null)
	im.surface_add_vertex(path_array[0])
	im.surface_add_vertex(path_array[path_array.size() - 1])
	im.surface_end()
	im.surface_begin(Mesh.PRIMITIVE_LINE_STRIP, null)
	for current_vector in path:
		im.surface_add_vertex(current_vector)
	im.surface_end()
