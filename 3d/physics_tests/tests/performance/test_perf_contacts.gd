extends Test


const OPTION_TYPE_ALL = "Shape type/All"
const OPTION_TYPE_BOX = "Shape type/Box"
const OPTION_TYPE_SPHERE = "Shape type/Sphere"
const OPTION_TYPE_CAPSULE = "Shape type/Capsule"
const OPTION_TYPE_CYLINDER = "Shape type/Cylinder"
const OPTION_TYPE_CONVEX = "Shape type/Convex"

export(Array) var spawns = Array()
export(int) var spawn_count = 100

var _object_templates = []

var _log_physics = false
var _log_physics_time = 0
var _log_physics_time_start = 0


func _ready():
	yield(start_timer(0.5), "timeout")
	if is_timer_canceled():
		return

	while $DynamicShapes.get_child_count():
		var type_node = $DynamicShapes.get_child(0)
		_object_templates.push_back(type_node)
		$DynamicShapes.remove_child(type_node)

	$Options.add_menu_item(OPTION_TYPE_ALL)
	$Options.add_menu_item(OPTION_TYPE_BOX)
	$Options.add_menu_item(OPTION_TYPE_SPHERE)
	$Options.add_menu_item(OPTION_TYPE_CAPSULE)
	$Options.add_menu_item(OPTION_TYPE_CYLINDER)
	$Options.add_menu_item(OPTION_TYPE_CONVEX)
	$Options.connect("option_selected", self, "_on_option_selected")

	_start_all_types()


func _exit_tree():
	for object_template in _object_templates:
		object_template.free()


func _physics_process(_delta):
	if _log_physics:
		var time = OS.get_ticks_usec()
		var time_delta = time - _log_physics_time
		var time_total = time - _log_physics_time_start
		_log_physics_time = time
		Log.print_log("  Physics Tick: %.3f ms (total = %.3f ms)" % [0.001 * time_delta, 0.001 * time_total])


func _log_physics_start():
	_log_physics = true
	_log_physics_time_start = OS.get_ticks_usec()
	_log_physics_time = _log_physics_time_start


func _log_physics_stop():
	_log_physics = false


func _on_option_selected(option):
	cancel_timer()

	_despawn_objects()

	match option:
		OPTION_TYPE_ALL:
			_start_all_types()
		OPTION_TYPE_BOX:
			_start_type(_find_type_index("Box"))
		OPTION_TYPE_SPHERE:
			_start_type(_find_type_index("Sphere"))
		OPTION_TYPE_CAPSULE:
			_start_type(_find_type_index("Capsule"))
		OPTION_TYPE_CYLINDER:
			_start_type(_find_type_index("Cylinder"))
		OPTION_TYPE_CONVEX:
			_start_type(_find_type_index("Convex"))


func _find_type_index(type_name):
	for type_index in range(_object_templates.size()):
		var type_node = _object_templates[type_index]
		if type_node.name.find(type_name) > -1:
			return type_index

	Log.print_error("Invalid shape type: " + type_name)
	return -1


func _start_type(type_index):
	if type_index < 0:
		return
	if type_index >= _object_templates.size():
		return

	yield(start_timer(1.0), "timeout")
	if is_timer_canceled():
		return

	_log_physics_start()

	_spawn_objects(type_index)

	yield(wait_for_physics_ticks(5), "wait_done")
	_log_physics_stop()

	yield(start_timer(1.0), "timeout")
	if is_timer_canceled():
		return

	_log_physics_start()

	_activate_objects()

	yield(wait_for_physics_ticks(5), "wait_done")
	_log_physics_stop()

	yield(start_timer(5.0), "timeout")
	if is_timer_canceled():
		return

	_log_physics_start()

	_despawn_objects()

	yield(wait_for_physics_ticks(5), "wait_done")
	_log_physics_stop()

	yield(start_timer(1.0), "timeout")


func _start_all_types():
	Log.print_log("* Start all types.")

	for type_index in range(_object_templates.size()):
		yield(_start_type(type_index), "completed")
		if is_timer_canceled():
			return

	Log.print_log("* Done all types.")


func _spawn_objects(type_index):
	var template_node = _object_templates[type_index]
	for spawn in spawns:
		var spawn_parent = get_node(spawn)

		Log.print_log("* Spawning: " + template_node.name)

		for _node_index in range(spawn_count):
			# Create a new object and shape every time to avoid the overhead of connecting many bodies to the same shape.
			var collision = template_node.get_child(0) as CollisionShape
			var shape = collision.shape.duplicate()
			var body = create_rigidbody(shape, false, collision.transform)
			body.set_sleeping(true)
			spawn_parent.add_child(body)


func _activate_objects():
	for spawn in spawns:
		var spawn_parent = get_node(spawn)

		Log.print_log("* Activating")

		for node_index in range(spawn_parent.get_child_count()):
			var node = spawn_parent.get_child(node_index) as RigidBody
			node.set_sleeping(false)


func _despawn_objects():
	for spawn in spawns:
		var spawn_parent = get_node(spawn)

		Log.print_log("* Despawning")

		# Remove objects in reversed order to avoid the overhead of changing children index in parent.
		var object_count = spawn_parent.get_child_count()
		for object_index in range(object_count):
			var node = spawn_parent.get_child(object_count - object_index - 1)
			spawn_parent.remove_child(node)
			node.queue_free()
