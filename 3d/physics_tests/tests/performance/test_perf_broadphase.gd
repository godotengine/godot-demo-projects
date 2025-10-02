extends Test

const BOX_SIZE = Vector3(0.8, 0.8, 0.8)
const BOX_SPACE = Vector3(1.0, 1.0, 1.0)

@export_range(1, 1000) var row_size := 20
@export_range(1, 1000) var column_size := 20
@export_range(1, 1000) var depth_size := 20

var _objects: Array[Node3D] = []

var _log_physics := false
var _log_physics_time := 0
var _log_physics_time_start := 0

func _ready() -> void:
	await start_timer(1.0).timeout
	if is_timer_canceled():
		return

	_log_physics_start()

	_create_objects()

	await wait_for_physics_ticks(5).wait_done
	_log_physics_stop()

	await start_timer(1.0).timeout
	if is_timer_canceled():
		return

	_log_physics_start()

	_add_objects()

	await wait_for_physics_ticks(5).wait_done
	_log_physics_stop()

	await start_timer(1.0).timeout
	if is_timer_canceled():
		return

	_log_physics_start()

	_move_objects()

	await wait_for_physics_ticks(5).wait_done
	_log_physics_stop()

	await start_timer(1.0).timeout
	if is_timer_canceled():
		return

	_log_physics_start()

	_remove_objects()

	await wait_for_physics_ticks(5).wait_done
	_log_physics_stop()

	await start_timer(1.0).timeout
	if is_timer_canceled():
		return

	Log.print_log("* Done.")


func _exit_tree() -> void:
	for object in _objects:
		object.free()


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


func _create_objects() -> void:
	_objects.clear()

	Log.print_log("* Creating objects...")
	var timer := Time.get_ticks_usec()

	var pos_x := -0.5 * (row_size - 1) * BOX_SPACE.x

	for row in row_size:
		var pos_y := -0.5 * (column_size - 1) * BOX_SPACE.y

		for column in column_size:
			var pos_z := -0.5 * (depth_size - 1) * BOX_SPACE.z

			for depth in depth_size:
				# Create a new object and shape every time to avoid the overhead of connecting many bodies to the same shape.
				var box: RigidBody3D = create_rigidbody_box(BOX_SIZE)
				box.gravity_scale = 0.0
				box.transform.origin = Vector3(pos_x, pos_y, pos_z)
				_objects.push_back(box)

				pos_z += BOX_SPACE.z

			pos_y += BOX_SPACE.y

		pos_x += BOX_SPACE.x

	timer = Time.get_ticks_usec() - timer
	Log.print_log("  Create Time: %.3f ms" % (0.001 * timer))


func _add_objects() -> void:
	var root_node: Node3D = $Objects

	Log.print_log("* Adding objects...")
	var timer := Time.get_ticks_usec()

	for object in _objects:
		root_node.add_child(object)

	timer = Time.get_ticks_usec() - timer
	Log.print_log("  Add Time: %.3f ms" % (0.001 * timer))


func _move_objects() -> void:
	Log.print_log("* Moving objects...")
	var timer := Time.get_ticks_usec()

	for object in _objects:
		object.transform.origin += BOX_SPACE

	timer = Time.get_ticks_usec() - timer
	Log.print_log("  Move Time: %.3f ms" % (0.001 * timer))


func _remove_objects() -> void:
	var root_node: Node3D = $Objects

	Log.print_log("* Removing objects...")
	var timer := Time.get_ticks_usec()

	# Remove objects in reversed order to avoid the overhead of changing children index in parent.
	var object_count := _objects.size()
	for object_index in object_count:
		root_node.remove_child(_objects[object_count - object_index - 1])

	timer = Time.get_ticks_usec() - timer
	Log.print_log("  Remove Time: %.3f ms" % (0.001 * timer))
