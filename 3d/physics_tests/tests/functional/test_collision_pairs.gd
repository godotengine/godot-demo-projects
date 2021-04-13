extends Test


const OPTION_TYPE_BOX = "Collision type/Box (1)"
const OPTION_TYPE_SPHERE = "Collision type/Sphere (2)"
const OPTION_TYPE_CAPSULE = "Collision type/Capsule (3)"
const OPTION_TYPE_CYLINDER = "Collision type/Cylinder (4)"
const OPTION_TYPE_CONVEX_POLYGON = "Collision type/Convex Polygon (5)"

const OPTION_SHAPE_BOX = "Shape type/Box"
const OPTION_SHAPE_SPHERE = "Shape type/Sphere"
const OPTION_SHAPE_CAPSULE = "Shape type/Capsule"
const OPTION_SHAPE_CYLINDER = "Shape type/Cylinder"
const OPTION_SHAPE_CONVEX_POLYGON = "Shape type/Convex Polygon"
const OPTION_SHAPE_CONCAVE_POLYGON = "Shape type/Concave Polygon"

const OFFSET_RANGE = 3.0

export(Vector3) var offset = Vector3.ZERO

var _update_collision = false
var _collision_test_index = 0
var _current_offset = Vector3.ZERO
var _collision_shapes = []


func _ready():
	_initialize_collision_shapes()

	$Options.add_menu_item(OPTION_TYPE_BOX)
	$Options.add_menu_item(OPTION_TYPE_SPHERE)
	$Options.add_menu_item(OPTION_TYPE_CAPSULE)
	$Options.add_menu_item(OPTION_TYPE_CYLINDER)
	$Options.add_menu_item(OPTION_TYPE_CONVEX_POLYGON)

	$Options.add_menu_item(OPTION_SHAPE_BOX, true, true)
	$Options.add_menu_item(OPTION_SHAPE_SPHERE, true, true)
	$Options.add_menu_item(OPTION_SHAPE_CAPSULE, true, true)
	$Options.add_menu_item(OPTION_SHAPE_CYLINDER, true, true)
	$Options.add_menu_item(OPTION_SHAPE_CONVEX_POLYGON, true, true)
	$Options.add_menu_item(OPTION_SHAPE_CONCAVE_POLYGON, true, true)

	$Options.connect("option_selected", self, "_on_option_selected")
	$Options.connect("option_changed", self, "_on_option_changed")

	yield(start_timer(0.5), "timeout")
	if is_timer_canceled():
		return

	_update_collision = true


func _input(event):
	var key_event = event as InputEventKey
	if key_event and not key_event.pressed:
		if key_event.scancode == KEY_1:
			_on_option_selected(OPTION_TYPE_BOX)
		elif key_event.scancode == KEY_2:
			_on_option_selected(OPTION_TYPE_SPHERE)
		elif key_event.scancode == KEY_3:
			_on_option_selected(OPTION_TYPE_CAPSULE)
		elif key_event.scancode == KEY_4:
			_on_option_selected(OPTION_TYPE_CYLINDER)
		elif key_event.scancode == KEY_5:
			_on_option_selected(OPTION_TYPE_CONVEX_POLYGON)


func _physics_process(_delta):
	if not _update_collision:
		return

	_update_collision = false

	_do_collision_test()


func set_x_offset(value):
	offset.x = value * OFFSET_RANGE
	_update_collision = true


func set_y_offset(value):
	offset.y = value * OFFSET_RANGE
	_update_collision = true


func set_z_offset(value):
	offset.z = value * OFFSET_RANGE
	_update_collision = true


func _initialize_collision_shapes():
	_collision_shapes.clear()

	for node in $Shapes.get_children():
		var body = node as PhysicsBody
		var shape = body.shape_owner_get_shape(0, 0)
		shape.resource_name = node.name.substr("RigidBody".length())

		_collision_shapes.push_back(shape)


func _do_collision_test():
	clear_drawn_nodes()

	var shape = _collision_shapes[_collision_test_index]

	Log.print_log("* Start %s collision tests..." % shape.resource_name)

	var shape_query = PhysicsShapeQueryParameters.new()
	shape_query.set_shape(shape)
	var shape_scale = Vector3(0.5, 0.5, 0.5)
	shape_query.transform = Transform.IDENTITY.scaled(shape_scale)

	for node in $Shapes.get_children():
		if not node.visible:
			continue

		var body = node as PhysicsBody
		var space_state = body.get_world().direct_space_state

		Log.print_log("* Testing: %s" % body.name)

		var center = body.global_transform.origin

		# Collision at the center inside.
		var res = _add_collision(space_state, center, shape, shape_query)
		Log.print_log("Collision center inside: %s" % ("NO HIT" if res.empty() else "HIT"))

	Log.print_log("* Done.")


func _add_collision(space_state, pos, shape, shape_query):
	shape_query.transform.origin = pos + offset
	var results = space_state.collide_shape(shape_query)

	var color
	if results.empty():
		color = Color.white.darkened(0.5)
	else:
		color = Color.green

	# Draw collision query shape.
	add_shape(shape, shape_query.transform, color)

	# Draw contact positions.
	for contact_pos in results:
		add_sphere(contact_pos, 0.05, Color.red)

	return results


func _on_option_selected(option):
	match option:
		OPTION_TYPE_BOX:
			_collision_test_index = _find_type_index("Box")
			_update_collision = true
		OPTION_TYPE_SPHERE:
			_collision_test_index = _find_type_index("Sphere")
			_update_collision = true
		OPTION_TYPE_CAPSULE:
			_collision_test_index = _find_type_index("Capsule")
			_update_collision = true
		OPTION_TYPE_CYLINDER:
			_collision_test_index = _find_type_index("Cylinder")
			_update_collision = true
		OPTION_TYPE_CONVEX_POLYGON:
			_collision_test_index = _find_type_index("ConvexPolygon")
			_update_collision = true


func _find_type_index(type_name):
	for type_index in range(_collision_shapes.size()):
		var type_shape = _collision_shapes[type_index]
		if type_shape.resource_name.find(type_name) > -1:
			return type_index

	Log.print_error("Invalid collision type: " + type_name)
	return -1


func _on_option_changed(option, checked):
	var node

	match option:
		OPTION_SHAPE_BOX:
			node = _find_shape_node("Box")
		OPTION_SHAPE_SPHERE:
			node = _find_shape_node("Sphere")
		OPTION_SHAPE_CAPSULE:
			node = _find_shape_node("Capsule")
		OPTION_SHAPE_CYLINDER:
			node = _find_shape_node("Cylinder")
		OPTION_SHAPE_CONVEX_POLYGON:
			node = _find_shape_node("ConvexPolygon")
		OPTION_SHAPE_CONCAVE_POLYGON:
			node = _find_shape_node("ConcavePolygon")

	if node:
		node.visible = checked
		node.get_child(0).disabled = not checked
		_update_collision = true


func _find_shape_node(type_name):
	var node = $Shapes.find_node("RigidBody%s" % type_name)

	if not node:
		Log.print_error("Invalid shape type: " + type_name)

	return node
