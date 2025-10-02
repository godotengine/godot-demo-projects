extends Test

const OPTION_TEST_CASE_HIT_FROM_INSIDE = "Test case/Hit from inside"

var _hit_from_inside := false
var _do_raycasts := false

func _ready() -> void:
	var options: OptionMenu = $Options

	options.add_menu_item(OPTION_TEST_CASE_HIT_FROM_INSIDE, true, false)

	options.option_changed.connect(_on_option_changed)

	await start_timer(0.5).timeout
	if is_timer_canceled():
		return

	_do_raycasts = true


func _physics_process(delta: float) -> void:
	super._physics_process(delta)

	if not _do_raycasts:
		return

	_do_raycasts = false

	Log.print_log("* Start Raycasting...")

	clear_drawn_nodes()

	for node in $Shapes.get_children():
		var body: PhysicsBody2D = node
		var space_state := body.get_world_2d().direct_space_state
		var body_name := String(body.name).substr("RigidBody".length())

		Log.print_log("* Testing: %s" % body_name)

		var center := body.position

		# Raycast entering from the top.
		var res: Dictionary = _add_raycast(space_state, center - Vector2(0, 100), center)
		Log.print_log("Raycast in: %s" % ("HIT" if res else "NO HIT"))

		# Raycast exiting from inside.
		center.x -= 20
		res = _add_raycast(space_state, center, center + Vector2(0, 200))
		Log.print_log("Raycast out: %s" % ("HIT" if res else "NO HIT"))

		# Raycast all inside.
		center.x += 40
		res = _add_raycast(space_state, center, center + Vector2(0, 40))
		Log.print_log("Raycast inside: %s" % ("HIT" if res else "NO HIT"))

		if body_name.begins_with("Concave"):
			# Raycast inside an internal face.
			center.x += 20
			res = _add_raycast(space_state, center, center + Vector2(0, 40))
			Log.print_log("Raycast inside face: %s" % ("HIT" if res else "NO HIT"))


func _on_option_changed(option: String, checked: bool) -> void:
	match option:
		OPTION_TEST_CASE_HIT_FROM_INSIDE:
			_hit_from_inside = checked
			_do_raycasts = true


func _add_raycast(space_state: PhysicsDirectSpaceState2D, pos_start: Vector2, pos_end: Vector2) -> Dictionary:
	var params := PhysicsRayQueryParameters2D.new()
	params.from = pos_start
	params.to = pos_end
	params.hit_from_inside = _hit_from_inside

	var result: Dictionary = space_state.intersect_ray(params)
	var color := Color.RED.darkened(0.5)
	if result:
		color = Color.GREEN.darkened(0.2)

	# Draw raycast line.
	add_line(pos_start, pos_end, color)

	# Draw raycast arrow.
	add_line(pos_end, pos_end + Vector2(-5, -10), color)
	add_line(pos_end, pos_end + Vector2(5, -10), color)

	if result:
		# Draw raycast hit position.
		var hit_pos: Vector2 = result.position
		add_circle(hit_pos, 4.0, Color.YELLOW)

		# Draw raycast hit normal.
		add_line(hit_pos, hit_pos + result.normal * 16.0, Color.YELLOW)

	return result
