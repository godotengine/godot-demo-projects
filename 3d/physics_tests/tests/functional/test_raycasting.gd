extends Test

const OPTION_TEST_CASE_HIT_FROM_INSIDE = "Test case/Hit from inside"

var _hit_from_inside := false
var _do_raycasts := false

@onready var _raycast_visuals := ImmediateMesh.new()
@onready var _material := StandardMaterial3D.new()


func _ready() -> void:
	var options: OptionMenu = $Options

	options.add_menu_item(OPTION_TEST_CASE_HIT_FROM_INSIDE, true, false)

	options.option_changed.connect(_on_option_changed)

	_material.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	_material.vertex_color_use_as_albedo = true

	var raycast_mesh_instance := MeshInstance3D.new()
	raycast_mesh_instance.mesh = _raycast_visuals
	add_child(raycast_mesh_instance)
	move_child(raycast_mesh_instance, get_child_count())

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

	_raycast_visuals.clear_surfaces()
	_raycast_visuals.surface_begin(Mesh.PRIMITIVE_LINES)

	for shape in $Shapes.get_children():
		var body: PhysicsBody3D = shape
		var space_state := body.get_world_3d().direct_space_state

		Log.print_log("* Testing: %s" % body.name)

		var center := body.global_transform.origin

		# Raycast entering from the top.
		var res := _add_raycast(space_state, center + Vector3(0.0, 2.0, 0.0), center)
		Log.print_log("Raycast in: %s" % ("HIT" if res else "NO HIT"))

		# Raycast exiting from inside.
		center.x -= 0.2
		res = _add_raycast(space_state, center, center - Vector3(0.0, 3.0, 0.0))
		Log.print_log("Raycast out: %s" % ("HIT" if res else "NO HIT"))

		# Raycast all inside.
		center.x += 0.4
		res = _add_raycast(space_state, center, center - Vector3(0.0, 0.8, 0.0))
		Log.print_log("Raycast inside: %s" % ("HIT" if res else "NO HIT"))

	_raycast_visuals.surface_end()

	_raycast_visuals.surface_set_material(0, _material)


func _on_option_changed(option: String, checked: bool) -> void:
	match option:
		OPTION_TEST_CASE_HIT_FROM_INSIDE:
			_hit_from_inside = checked
			_do_raycasts = true


func _add_raycast(space_state: PhysicsDirectSpaceState3D, pos_start: Vector3, pos_end: Vector3) -> Dictionary:
	var params := PhysicsRayQueryParameters3D.new()
	params.from = pos_start
	params.to = pos_end
	params.hit_from_inside = _hit_from_inside

	var result := space_state.intersect_ray(params)
	if result:
		_raycast_visuals.surface_set_color(Color.GREEN)
	else:
		_raycast_visuals.surface_set_color(Color.RED.darkened(0.5))

	# Draw raycast line.
	_raycast_visuals.surface_add_vertex(pos_start)
	_raycast_visuals.surface_add_vertex(pos_end)

	# Draw raycast arrow.
	_raycast_visuals.surface_add_vertex(pos_end)
	_raycast_visuals.surface_add_vertex(pos_end + Vector3(-0.05, 0.1, 0.0))
	_raycast_visuals.surface_add_vertex(pos_end)
	_raycast_visuals.surface_add_vertex(pos_end + Vector3(0.05, 0.1, 0.0))

	return result
