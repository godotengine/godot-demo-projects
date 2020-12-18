extends Test


var _do_raycasts = false


func _ready():
	yield(start_timer(0.5), "timeout")
	if is_timer_canceled():
		return

	_do_raycasts = true


func _physics_process(_delta):
	if not _do_raycasts:
		return

	_do_raycasts = false

	Log.print_log("* Start Raycasting...")

	clear_drawn_nodes()

	for node in $Shapes.get_children():
		var body = node as PhysicsBody2D
		var space_state = body.get_world_2d().direct_space_state
		var body_name = body.name.substr("RigidBody".length())

		Log.print_log("* Testing: %s" % body_name)

		var center = body.position

		# Raycast entering from the top.
		var res = _add_raycast(space_state, center - Vector2(0, 100), center)
		Log.print_log("Raycast in: %s" % ("HIT" if res else "NO HIT"))

		# Raycast exiting from inside.
		center.x -= 20
		res = _add_raycast(space_state, center, center + Vector2(0, 200))
		Log.print_log("Raycast out: %s" % ("HIT" if res else "NO HIT"))

		# Raycast all inside.
		center.x += 40
		res = _add_raycast(space_state, center, center + Vector2(0, 40))
		Log.print_log("Raycast inside: %s" % ("HIT" if res else "NO HIT"))

		if body.name.ends_with("ConcavePolygon"):
			# Raycast inside an internal face.
			center.x += 20
			res = _add_raycast(space_state, center, center + Vector2(0, 40))
			Log.print_log("Raycast inside face: %s" % ("HIT" if res else "NO HIT"))


func _add_raycast(space_state, pos_start, pos_end):
	var result = space_state.intersect_ray(pos_start, pos_end)
	var color
	if result:
		color = Color.green
	else:
		color = Color.red.darkened(0.5)

	# Draw raycast line.
	add_line(pos_start, pos_end, color)

	# Draw raycast arrow.
	add_line(pos_end, pos_end + Vector2(-5, -10), color)
	add_line(pos_end, pos_end + Vector2(5, -10), color)

	return result
