extends Test

const OPTION_BIG = "Floor options/Big"
const OPTION_SMALL = "Floor options/Small"

const SHAPE_CONCAVE = "Collision shapes/Concave"
const SHAPE_CONVEX = "Collision shapes/Convex"
const SHAPE_BOX = "Collision shapes/Box"

var _dynamic_shapes_scene: PackedScene
var _floor_shapes := {}
var _floor_size := "Small"

var _current_floor_name := SHAPE_CONCAVE
var _current_bodies: Node3D
var _current_floor: Node3D

func _ready() -> void:
	var options: OptionMenu = $Options
	_dynamic_shapes_scene = get_packed_scene($DynamicShapes/Bodies)
	_floor_shapes[SHAPE_CONVEX + "Small"] = get_packed_scene($"Floors/ConvexSmall")
	_floor_shapes[SHAPE_CONVEX + "Big"] = get_packed_scene($"Floors/ConvexBig")
	_floor_shapes[SHAPE_CONCAVE + "Big"] = get_packed_scene($"Floors/ConcaveBig")
	_floor_shapes[SHAPE_CONCAVE + "Small"] = get_packed_scene($"Floors/ConcaveSmall")
	_floor_shapes[SHAPE_BOX + "Big"] = get_packed_scene($"Floors/BoxBig")
	_floor_shapes[SHAPE_BOX + "Small"] = get_packed_scene($"Floors/BoxSmall")
	$DynamicShapes/Bodies.queue_free()
	for floorNode in $Floors.get_children():
		floorNode.queue_free()

	options.add_menu_item(OPTION_SMALL)
	options.add_menu_item(OPTION_BIG)
	options.add_menu_item(SHAPE_CONCAVE)
	options.add_menu_item(SHAPE_CONVEX)
	options.add_menu_item(SHAPE_BOX)

	options.option_selected.connect(_on_option_selected)
	restart_scene()


func _on_option_selected(option: String) -> void:
	match option:
		OPTION_BIG:
			_floor_size = "Big"
		OPTION_SMALL:
			_floor_size = "Small"
		_:
			_current_floor_name = option
	restart_scene()


func restart_scene() -> void:
	if _current_bodies:
		_current_bodies.queue_free()
	if _current_floor:
		_current_floor.queue_free()

	var dynamic_bodies := _dynamic_shapes_scene.instantiate()
	_current_bodies = dynamic_bodies
	add_child(dynamic_bodies)

	var floor_inst: Node3D = _floor_shapes[_current_floor_name + _floor_size].instantiate()
	_current_floor = floor_inst
	$Floors.add_child(floor_inst)

	$LabelBodyType.text = "Floor Type: " + _current_floor_name.rsplit("/", true, 1)[1] + "\nSize: " + _floor_size


func get_packed_scene(node: Node) -> PackedScene:
	for child in node.get_children():
		child.owner = node
		for child1 in child.get_children():
			child1.owner = node
			for child2 in child1.get_children():
				child2.owner = node

	var packed_scene := PackedScene.new()
	packed_scene.pack(node)
	return packed_scene
