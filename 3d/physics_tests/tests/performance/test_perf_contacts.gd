extends Test

const OPTION_TYPE_ALL = "Shape type/All"
const OPTION_TYPE_BOX = "Shape type/Box"
const OPTION_TYPE_SPHERE = "Shape type/Sphere"
const OPTION_TYPE_CAPSULE = "Shape type/Capsule"
const OPTION_TYPE_CYLINDER = "Shape type/Cylinder"
const OPTION_TYPE_CONVEX = "Shape type/Convex"

@export var spawns: Array[NodePath] = []
@export var spawn_count := 100
@export var spawn_randomize := Vector3.ZERO

var _object_templates: Array[Node3D] = []

var _log_physics := false
var _log_physics_time := 0
var _log_physics_time_start := 0

func _ready() -> void:
	await start_timer(0.5).timeout
	if is_timer_canceled():
		return

	while $DynamicShapes.get_child_count():
		var type_node: Node3D = $DynamicShapes.get_child(0)
		_object_templates.push_back(type_node)
		$DynamicShapes.remove_child(type_node)

	$Options.add_menu_item(OPTION_TYPE_ALL)
	$Options.add_menu_item(OPTION_TYPE_BOX)
	$Options.add_menu_item(OPTION_TYPE_SPHERE)
	$Options.add_menu_item(OPTION_TYPE_CAPSULE)
	$Options.add_menu_item(OPTION_TYPE_CYLINDER)
	$Options.add_menu_item(OPTION_TYPE_CONVEX)
	$Options.option_selected.connect(_on_option_selected)

	await _start_all_types()


func _exit_tree() -> void:
	for object_template in _object_templates:
		object_template.free()


func _physics_process(delta: float) -> void:
	super._physics_process(delta)

	if _log_physics:
		var time := Time.get_ticks_usec()
		var time_delta := time - _log_physics_time
		var time_total := time - _log_physics_time_start
		_log_physics_time = time
		Log.print_log("  Physics Tick: %.3f ms (total = %.3f ms)" % [0.001 * time_delta, 0.001 * time_total])


func _log_physics_start() -> void:
	_log_physics = true
	_log_physics_time_start = Time.get_ticks_usec()
	_log_physics_time = _log_physics_time_start


func _log_physics_stop() -> void:
	_log_physics = false


func _on_option_selected(option: String) -> void:
	cancel_timer()

	_despawn_objects()

	match option:
		OPTION_TYPE_ALL:
			await _start_all_types()
		OPTION_TYPE_BOX:
			await _start_type(_find_type_index("Box"))
		OPTION_TYPE_SPHERE:
			await _start_type(_find_type_index("Sphere"))
		OPTION_TYPE_CAPSULE:
			await _start_type(_find_type_index("Capsule"))
		OPTION_TYPE_CYLINDER:
			await _start_type(_find_type_index("Cylinder"))
		OPTION_TYPE_CONVEX:
			await _start_type(_find_type_index("Convex"))


func _find_type_index(type_name: String) -> int:
	for type_index in range(_object_templates.size()):
		var type_node := _object_templates[type_index]
		if String(type_node.name).find(type_name) > -1:
			return type_index

	Log.print_error("Invalid shape type: " + type_name)
	return -1


func _start_type(type_index: int) -> void:
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


func _start_all_types() -> void:
	Log.print_log("* Start all types.")

	for type_index in _object_templates.size():
		await _start_type(type_index)
		if is_timer_canceled():
			return

	Log.print_log("* Done all types.")


func _spawn_objects(type_index: int) -> void:
	var template_node := _object_templates[type_index]

	Log.print_log("* Spawning: " + String(template_node.name))

	for spawn in spawns:
		var spawn_parent := get_node(spawn)

		for _node_index in range(spawn_count):
			# Create a new object and shape every time to avoid the overhead of connecting many bodies to the same shape.
			var collision := template_node.get_child(0).duplicate()
			collision.shape = collision.shape.duplicate()
			var body := template_node.duplicate()
			body.transform = Transform3D.IDENTITY
			if spawn_randomize != Vector3.ZERO:
				body.transform.origin.x = randf() * spawn_randomize.x
				body.transform.origin.y = randf() * spawn_randomize.y
				body.transform.origin.z = randf() * spawn_randomize.z
			var prev_collision := body.get_child(0)
			body.remove_child(prev_collision)
			prev_collision.queue_free()
			body.add_child(collision)
			body.set_sleeping(true)
			spawn_parent.add_child(body)


func _activate_objects() -> void:
	Log.print_log("* Activating")

	for spawn in spawns:
		var spawn_parent := get_node(spawn)

		for node_index in spawn_parent.get_child_count():
			var node: RigidBody3D = spawn_parent.get_child(node_index)
			node.set_sleeping(false)


func _despawn_objects() -> void:
	Log.print_log("* Despawning")

	for spawn in spawns:
		var spawn_parent := get_node(spawn)

		# Remove objects in reversed order to avoid the overhead of changing children index in parent.
		var object_count := spawn_parent.get_child_count()
		for object_index in object_count:
			var node := spawn_parent.get_child(object_count - object_index - 1)
			spawn_parent.remove_child(node)
			node.queue_free()
