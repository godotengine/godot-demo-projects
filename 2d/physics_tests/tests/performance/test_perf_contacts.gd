extends Test


const OPTION_TYPE_ALL = "Shape type/All"
const OPTION_TYPE_RECTANGLE = "Shape type/Rectangle"
const OPTION_TYPE_SPHERE = "Shape type/Sphere"
const OPTION_TYPE_CAPSULE = "Shape type/Capsule"
const OPTION_TYPE_CONVEX_POLYGON = "Shape type/Convex Polygon"
const OPTION_TYPE_CONCAVE_POLYGON = "Shape type/Concave Polygon"

@export var spawns = []
@export var spawn_count = 100
@export var spawn_randomize = Vector2.ZERO

@onready var options = $Options

var _object_templates = []

var _log_physics = false
var _log_physics_time = 0
var _log_physics_time_start = 0


func _ready():
	await start_timer(0.5).timeout
	if is_timer_canceled():
		return

	var dynamic_shapes = $DynamicShapes
	while dynamic_shapes.get_child_count():
		var type_node = dynamic_shapes.get_child(0)
		type_node.position = Vector2.ZERO
		_object_templates.push_back(type_node)
		dynamic_shapes.remove_child(type_node)

	options.add_menu_item(OPTION_TYPE_ALL)
	options.add_menu_item(OPTION_TYPE_RECTANGLE)
	options.add_menu_item(OPTION_TYPE_SPHERE)
	options.add_menu_item(OPTION_TYPE_CAPSULE)
	options.add_menu_item(OPTION_TYPE_CONVEX_POLYGON)
	options.add_menu_item(OPTION_TYPE_CONCAVE_POLYGON)
	options.option_selected.connect(self._on_option_selected)

	await _start_all_types()


func _physics_process(delta):
	super._physics_process(delta)

	if _log_physics:
		var time = Time.get_ticks_usec()
		var time_delta = time - _log_physics_time
		var time_total = time - _log_physics_time_start
		_log_physics_time = time
		Log.print_log("  Physics Tick: %.3f ms (total = %.3f ms)" % [0.001 * time_delta, 0.001 * time_total])


func _log_physics_start():
	_log_physics = true
	_log_physics_time_start = Time.get_ticks_usec()
	_log_physics_time = _log_physics_time_start


func _log_physics_stop():
	_log_physics = false


func _exit_tree():
	for object_template in _object_templates:
		object_template.free()


func _on_option_selected(option):
	cancel_timer()

	_despawn_objects()

	match option:
		OPTION_TYPE_ALL:
			await _start_all_types()
		OPTION_TYPE_RECTANGLE:
			await _start_type(_find_type_index("Rectangle"))
		OPTION_TYPE_SPHERE:
			await _start_type(_find_type_index("Sphere"))
		OPTION_TYPE_CAPSULE:
			await _start_type(_find_type_index("Capsule"))
		OPTION_TYPE_CONVEX_POLYGON:
			await _start_type(_find_type_index("ConvexPolygon"))
		OPTION_TYPE_CONCAVE_POLYGON:
			await _start_type(_find_type_index("ConcavePolygon"))


func _find_type_index(type_name):
	for type_index in range(_object_templates.size()):
		var type_node = _object_templates[type_index]
		if String(type_node.name).find(type_name) > -1:
			return type_index

	Log.print_error("Invalid shape type: " + type_name)
	return -1


func _start_type(type_index):
	if type_index < 0:
		return
	if type_index >= _object_templates.size():
		return

	await start_timer(1.0).timeout
	if is_timer_canceled():
		return

	_log_physics_start()

	_spawn_objects(type_index)

	await wait_for_physics_ticks(5).wait_done
	_log_physics_stop()

	await start_timer(1.0).timeout
	if is_timer_canceled():
		return

	_log_physics_start()

	_activate_objects()

	await wait_for_physics_ticks(5).wait_done
	_log_physics_stop()

	await start_timer(5.0).timeout
	if is_timer_canceled():
		return

	_log_physics_start()

	_despawn_objects()

	await wait_for_physics_ticks(5).wait_done
	_log_physics_stop()

	await start_timer(1.0).timeout


func _start_all_types():
	Log.print_log("* Start all types.")

	for type_index in range(_object_templates.size()):
		await _start_type(type_index)
		if is_timer_canceled():
			return

	Log.print_log("* Done all types.")


func _spawn_objects(type_index):
	var template_node = _object_templates[type_index]

	Log.print_log("* Spawning: " + String(template_node.name))

	for spawn in spawns:
		var spawn_parent = get_node(spawn)

		for _node_index in range(spawn_count):
			# Create a new object and shape every time to avoid the overhead of connecting many bodies to the same shape.
			var collision = template_node.get_child(0).duplicate()
			if collision is CollisionShape2D:
				collision.shape = collision.shape.duplicate()
			var body = template_node.duplicate()
			body.transform = Transform2D.IDENTITY
			if spawn_randomize != Vector2.ZERO:
				body.position.x = randf() * spawn_randomize.x
				body.position.y = randf() * spawn_randomize.y
			var prev_collision = body.get_child(0)
			body.remove_child(prev_collision)
			prev_collision.queue_free()
			body.add_child(collision)
			body.set_sleeping(true)
			spawn_parent.add_child(body)


func _activate_objects():
	Log.print_log("* Activating")

	for spawn in spawns:
		var spawn_parent = get_node(spawn)

		for node_index in range(spawn_parent.get_child_count()):
			var node = spawn_parent.get_child(node_index) as RigidBody2D
			node.set_sleeping(false)


func _despawn_objects():
	Log.print_log("* Despawning")

	for spawn in spawns:
		var spawn_parent = get_node(spawn)

		var object_count = spawn_parent.get_child_count()
		if object_count == 0:
			continue

		# Remove objects in reversed order to avoid the overhead of changing children index in parent.
		for object_index in range(object_count):
			var node = spawn_parent.get_child(object_count - object_index - 1)
			spawn_parent.remove_child(node)
			node.queue_free()
