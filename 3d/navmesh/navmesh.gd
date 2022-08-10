extends Spatial


const SPEED = 10.0

var camrot = 0.0
var m = SpatialMaterial.new()

var map

var path = []
var show_path = true

onready var robot  = get_node("RobotBase")
onready var camera = get_node("CameraBase/Camera")


func _ready():
	set_process_input(true)
	m.flags_unshaded = true
	m.flags_use_point_size = true
	m.albedo_color = Color.white

	# use call deferred to make sure the entire SceneTree Nodes are setup
	# else yield on 'physics_frame' in a _ready() might get stuck
	call_deferred("setup_navserver")


func _physics_process(delta):
	var direction = Vector3()

	# We need to scale the movement speed by how much delta has passed,
	# otherwise the motion won't be smooth.
	var step_size = delta * SPEED

	if path.size() > 0:
		# Direction is the difference between where we are now
		# and where we want to go.
		var destination = path[0]
		direction = destination - robot.translation

		# If the next node is closer than we intend to 'step', then
		# take a smaller step. Otherwise we would go past it and
		# potentially go through a wall or over a cliff edge!
		if step_size > direction.length():
			step_size = direction.length()
			# We should also remove this node since we're about to reach it.
			path.remove(0)

		# Move the robot towards the path node, by how far we want to travel.
		# Note: For a KinematicBody, we would instead use move_and_slide
		# so collisions work properly.
		robot.translation += direction.normalized() * step_size

		# Lastly let's make sure we're looking in the direction we're traveling.
		# Clamp y to 0 so the robot only looks left and right, not up/down.
		direction.y = 0
		if direction:
			# Direction is relative, so apply it to the robot's location to
			# get a point we can actually look at.
			var look_at_point = robot.translation + direction.normalized()
			# Make the robot look at the point.
			robot.look_at(look_at_point, Vector3.UP)


func setup_navserver():
	# create a new navigation map
	map = NavigationServer.map_create()
	NavigationServer.map_set_up(map, Vector3.UP)
	NavigationServer.map_set_active(map, true)

	# create a new navigation region and add it to the map
	var region = NavigationServer.region_create()
	NavigationServer.region_set_transform(region, Transform())
	NavigationServer.region_set_map(region, map)

	# sets navigation mesh for the region
	var navigation_mesh = NavigationMesh.new()
	navigation_mesh = $NavigationMeshInstance_Level.navmesh
	NavigationServer.region_set_navmesh(region, navigation_mesh)

	# wait for NavigationServer sync to adapt to made changes
	yield(get_tree(), "physics_frame")


func _unhandled_input(event):
	if event is InputEventMouseButton and event.button_index == BUTTON_LEFT and event.pressed:
		# get closest point on navmesh for the current mouse cursor position
		var mouse_cursor_position : Vector2 = event.position
		var camera_ray_length : float = 1000.0
		var camera_ray_start : Vector3 = camera.project_ray_origin(mouse_cursor_position)
		var camera_ray_end : Vector3 = camera_ray_start + camera.project_ray_normal(mouse_cursor_position) * camera_ray_length
		var navigation_map : RID = get_world().get_navigation_map()

		var closest_point_on_navmesh : Vector3 = NavigationServer.map_get_closest_point_to_segment(
			navigation_map,
			camera_ray_start,
			camera_ray_end
			)

		# get a full navigation path with the NavigationServer API
		var start_position : Vector3 = robot.global_transform.origin
		var target_position : Vector3 = closest_point_on_navmesh
		var optimize : bool = true
		path = NavigationServer.map_get_path(
			navigation_map,
			start_position,
			target_position,
			optimize
			)
		if show_path:
			draw_path(path)

	if event is InputEventMouseMotion:
		if event.button_mask & (BUTTON_MASK_MIDDLE + BUTTON_MASK_RIGHT):
			camrot += event.relative.x * 0.005
			get_node("CameraBase").set_rotation(Vector3(0, camrot, 0))
			print("Camera Rotation: ", camrot)


func draw_path(path_array):
	var im = get_node("Draw")
	im.set_material_override(m)
	im.clear()
	im.begin(Mesh.PRIMITIVE_POINTS, null)
	im.add_vertex(path_array[0])
	im.add_vertex(path_array[path_array.size() - 1])
	im.end()
	im.begin(Mesh.PRIMITIVE_LINE_STRIP, null)
	for x in path:
		im.add_vertex(x)
	im.end()
