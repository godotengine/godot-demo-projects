extends Test


var _do_raycasts = false

onready var _raycast_visuals = ImmediateGeometry.new()


func _ready():
	var material = SpatialMaterial.new()
	material.flags_unshaded = true
	material.vertex_color_use_as_albedo = true
	_raycast_visuals.material_override = material

	add_child(_raycast_visuals)
	move_child(_raycast_visuals, get_child_count())

	yield(start_timer(0.5), "timeout")
	if is_timer_canceled():
		return

	_do_raycasts = true


func _physics_process(_delta):
	if not _do_raycasts:
		return

	_do_raycasts = false

	Log.print_log("* Start Raycasting...")

	_raycast_visuals.clear()
	_raycast_visuals.begin(Mesh.PRIMITIVE_LINES)

	for shape in $Shapes.get_children():
		var body = shape as PhysicsBody
		var space_state = body.get_world().direct_space_state

		Log.print_log("* Testing: %s" % body.name)

		var center = body.global_transform.origin

		# Raycast entering from the top.
		var res = _add_raycast(space_state, center + Vector3(0.0, 2.0, 0.0), center)
		Log.print_log("Raycast in: %s" % ("HIT" if res else "NO HIT"))

		# Raycast exiting from inside.
		center.x -= 0.2
		res = _add_raycast(space_state, center, center - Vector3(0.0, 3.0, 0.0))
		Log.print_log("Raycast out: %s" % ("HIT" if res else "NO HIT"))

		# Raycast all inside.
		center.x += 0.4
		res = _add_raycast(space_state, center, center - Vector3(0.0, 0.8, 0.0))
		Log.print_log("Raycast inside: %s" % ("HIT" if res else "NO HIT"))

	_raycast_visuals.end()


func _add_raycast(space_state, pos_start, pos_end):
	var result = space_state.intersect_ray(pos_start, pos_end)
	if result:
		_raycast_visuals.set_color(Color.green)
	else:
		_raycast_visuals.set_color(Color.red.darkened(0.5))

	# Draw raycast line.
	_raycast_visuals.add_vertex(pos_start)
	_raycast_visuals.add_vertex(pos_end)

	# Draw raycast arrow.
	_raycast_visuals.add_vertex(pos_end)
	_raycast_visuals.add_vertex(pos_end + Vector3(-0.05, 0.1, 0.0))
	_raycast_visuals.add_vertex(pos_end)
	_raycast_visuals.add_vertex(pos_end + Vector3(0.05, 0.1, 0.0))

	return result
