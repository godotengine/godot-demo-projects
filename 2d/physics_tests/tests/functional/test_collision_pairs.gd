extends Test

const OPTION_TYPE_RECTANGLE = "Collision type/Rectangle (1)"
const OPTION_TYPE_SPHERE = "Collision type/Sphere (2)"
const OPTION_TYPE_CAPSULE = "Collision type/Capsule (3)"
const OPTION_TYPE_CONVEX_POLYGON = "Collision type/Convex Polygon (4)"
const OPTION_TYPE_CONCAVE_SEGMENTS = "Collision type/Concave Segments (5)"

const OPTION_SHAPE_RECTANGLE = "Shape type/Rectangle"
const OPTION_SHAPE_SPHERE = "Shape type/Sphere"
const OPTION_SHAPE_CAPSULE = "Shape type/Capsule"
const OPTION_SHAPE_CONVEX_POLYGON = "Shape type/Convex Polygon"
const OPTION_SHAPE_CONCAVE_POLYGON = "Shape type/Concave Polygon"
const OPTION_SHAPE_CONCAVE_SEGMENTS = "Shape type/Concave Segments"

const OFFSET_RANGE = 120.0

@export var offset := Vector2.ZERO

@onready var options: OptionMenu = $Options

var _update_collision := false
var _collision_test_index := 0
var _collision_shapes: Array[Shape2D] = []


func _ready() -> void:
	_initialize_collision_shapes()

	options.add_menu_item(OPTION_TYPE_RECTANGLE)
	options.add_menu_item(OPTION_TYPE_SPHERE)
	options.add_menu_item(OPTION_TYPE_CAPSULE)
	options.add_menu_item(OPTION_TYPE_CONVEX_POLYGON)
	options.add_menu_item(OPTION_TYPE_CONCAVE_SEGMENTS)

	options.add_menu_item(OPTION_SHAPE_RECTANGLE, true, true)
	options.add_menu_item(OPTION_SHAPE_SPHERE, true, true)
	options.add_menu_item(OPTION_SHAPE_CAPSULE, true, true)
	options.add_menu_item(OPTION_SHAPE_CONVEX_POLYGON, true, true)
	options.add_menu_item(OPTION_SHAPE_CONCAVE_POLYGON, true, true)
	options.add_menu_item(OPTION_SHAPE_CONCAVE_SEGMENTS, true, true)

	options.option_selected.connect(_on_option_selected)
	options.option_changed.connect(_on_option_changed)

	await start_timer(0.5).timeout
	if is_timer_canceled():
		return

	_update_collision = true


func _input(event: InputEvent) -> void:
	var key_event := event as InputEventKey
	if key_event and not key_event.pressed:
		if key_event.keycode == KEY_1:
			_on_option_selected(OPTION_TYPE_RECTANGLE)
		elif key_event.keycode == KEY_2:
			_on_option_selected(OPTION_TYPE_SPHERE)
		elif key_event.keycode == KEY_3:
			_on_option_selected(OPTION_TYPE_CAPSULE)
		elif key_event.keycode == KEY_4:
			_on_option_selected(OPTION_TYPE_CONVEX_POLYGON)
		elif key_event.keycode == KEY_5:
			_on_option_selected(OPTION_TYPE_CONCAVE_SEGMENTS)


func _physics_process(delta: float) -> void:
	super._physics_process(delta)

	if not _update_collision:
		return

	_update_collision = false

	_do_collision_test()


func set_h_offset(value: float) -> void:
	offset.x = value * OFFSET_RANGE
	_update_collision = true


func set_v_offset(value: float) -> void:
	offset.y = -value * OFFSET_RANGE
	_update_collision = true


func _initialize_collision_shapes() -> void:
	_collision_shapes.clear()

	for node: PhysicsBody2D in $Shapes.get_children():
		var body: PhysicsBody2D = node
		var shape := body.shape_owner_get_shape(0, 0)
		shape.resource_name = String(node.name).substr("RigidBody".length())

		_collision_shapes.push_back(shape)


func _do_collision_test() -> void:
	clear_drawn_nodes()

	var shape := _collision_shapes[_collision_test_index]

	Log.print_log("* Start %s collision tests..." % shape.resource_name)

	var shape_query := PhysicsShapeQueryParameters2D.new()
	shape_query.set_shape(shape)
	var shape_scale := Vector2(0.5, 0.5)
	shape_query.transform = Transform2D.IDENTITY.scaled(shape_scale)

	for node: PhysicsBody2D in $Shapes.get_children():
		if not node.visible:
			continue

		var body: PhysicsBody2D = node
		var space_state := body.get_world_2d().direct_space_state

		Log.print_log("* Testing: %s" % String(body.name))

		var center := body.position

		# Collision at the center inside.
		var res := _add_collision(space_state, center, shape, shape_query)
		Log.print_log("Collision center inside: %s" % ("NO HIT" if res.is_empty() else "HIT"))

	Log.print_log("* Done.")


func _add_collision(space_state: PhysicsDirectSpaceState2D, pos: Vector2, shape: Shape2D, shape_query: PhysicsShapeQueryParameters2D) -> Array[Vector2]:
	shape_query.transform.origin = pos + offset
	var results: Array[Vector2] = space_state.collide_shape(shape_query)

	var color := Color.GREEN
	if results.is_empty():
		color = Color.WHITE.darkened(0.5)

	# Draw collision query shape.
	add_shape(shape, shape_query.transform, color)

	# Draw contact positions.
	for contact_pos in results:
		add_circle(contact_pos, 1.0, Color.RED)

	return results


func _on_option_selected(option: String) -> void:
	match option:
		OPTION_TYPE_RECTANGLE:
			_collision_test_index = _find_type_index("Rectangle")
			_update_collision = true
		OPTION_TYPE_SPHERE:
			_collision_test_index = _find_type_index("Sphere")
			_update_collision = true
		OPTION_TYPE_CAPSULE:
			_collision_test_index = _find_type_index("Capsule")
			_update_collision = true
		OPTION_TYPE_CONVEX_POLYGON:
			_collision_test_index = _find_type_index("ConvexPolygon")
			_update_collision = true
		OPTION_TYPE_CONCAVE_SEGMENTS:
			_collision_test_index = _find_type_index("ConcaveSegments")
			_update_collision = true


func _find_type_index(type_name: String) -> int:
	for type_index in range(_collision_shapes.size()):
		var type_shape := _collision_shapes[type_index]
		if type_shape.resource_name.find(type_name) > -1:
			return type_index

	Log.print_error("Invalid collision type: " + type_name)
	return -1


func _on_option_changed(option: String, checked: bool) -> void:
	var node: Node2D

	match option:
		OPTION_SHAPE_RECTANGLE:
			node = _find_shape_node("Rectangle")
		OPTION_SHAPE_SPHERE:
			node = _find_shape_node("Sphere")
		OPTION_SHAPE_CAPSULE:
			node = _find_shape_node("Capsule")
		OPTION_SHAPE_CONVEX_POLYGON:
			node = _find_shape_node("ConvexPolygon")
		OPTION_SHAPE_CONCAVE_POLYGON:
			node = _find_shape_node("ConcavePolygon")
		OPTION_SHAPE_CONCAVE_SEGMENTS:
			node = _find_shape_node("ConcaveSegments")

	if node:
		node.visible = checked
		node.get_child(0).disabled = not checked
		_update_collision = true


func _find_shape_node(type_name: String) -> Node2D:
	var node: Node2D = $Shapes.find_child("RigidBody%s" % type_name)

	if not node:
		Log.print_error("Invalid shape type: " + type_name)

	return node
