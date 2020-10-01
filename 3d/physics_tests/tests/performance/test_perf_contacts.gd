extends Test


const OPTION_TYPE_ALL = "Shape type/All"
const OPTION_TYPE_BOX = "Shape type/Box"
const OPTION_TYPE_CAPSULE = "Shape type/Capsule"
const OPTION_TYPE_CYLINDER = "Shape type/Cylinder"
const OPTION_TYPE_CONVEX = "Shape type/Convex"
const OPTION_TYPE_SPHERE = "Shape type/Sphere"
export(Array) var spawns = Array()

export(int) var spawn_count = 100
export(int, 1, 10) var spawn_multipiler = 5

var _object_templates = []


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
	$Options.add_menu_item(OPTION_TYPE_CAPSULE)
	$Options.add_menu_item(OPTION_TYPE_CYLINDER)
	$Options.add_menu_item(OPTION_TYPE_CONVEX)
	$Options.add_menu_item(OPTION_TYPE_SPHERE)
	$Options.connect("option_selected", self, "_on_option_selected")

	_start_all_types()


func _on_option_selected(option):
	cancel_timer()

	_despawn_objects()

	match option:
		OPTION_TYPE_ALL:
			_start_all_types()
		OPTION_TYPE_BOX:
			_start_type(_find_type_index("Box"))
		OPTION_TYPE_CAPSULE:
			_start_type(_find_type_index("Capsule"))
		OPTION_TYPE_CYLINDER:
			_start_type(_find_type_index("Cylinder"))
		OPTION_TYPE_CONVEX:
			_start_type(_find_type_index("Convex"))
		OPTION_TYPE_SPHERE:
			_start_type(_find_type_index("Sphere"))


func _find_type_index(type_name):
	for type_index in _object_templates.size():
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

	_spawn_objects(type_index)

	yield(start_timer(1.0), "timeout")
	if is_timer_canceled():
		return

	_activate_objects()

	yield(start_timer(5.0), "timeout")
	if is_timer_canceled():
		return

	_despawn_objects()

	Log.print_log("* Done.")


func _start_all_types():
	for type_index in _object_templates.size():
		yield(start_timer(1.0), "timeout")
		if is_timer_canceled():
			return

		_spawn_objects(type_index)

		yield(start_timer(1.0), "timeout")
		if is_timer_canceled():
			return

		_activate_objects()

		yield(start_timer(5.0), "timeout")
		if is_timer_canceled():
			return

		_despawn_objects()

	Log.print_log("* Done.")


func _spawn_objects(type_index):
	var template_node = _object_templates[type_index]
	for spawn in spawns:
		var spawn_parent = get_node(spawn)

		Log.print_log("* Spawning: " + template_node.name)

		for _index in range(spawn_multipiler):
			for _node_index in spawn_count / spawn_multipiler:
				var node = template_node.duplicate() as Spatial
				spawn_parent.add_child(node)


func _activate_objects():
	var spawn_parent = $SpawnTarget1

	Log.print_log("* Activating")

	for node_index in spawn_parent.get_child_count():
		var node = spawn_parent.get_child(node_index) as RigidBody
		node.set_sleeping(false)


func _despawn_objects():
	for spawn in spawns:
		var spawn_parent = get_node(spawn)

		if spawn_parent.get_child_count() == 0:
			return

		Log.print_log("* Despawning")

		while spawn_parent.get_child_count():
			var node_index = spawn_parent.get_child_count() - 1
			var node = spawn_parent.get_child(node_index)
			spawn_parent.remove_child(node)
			node.queue_free()
