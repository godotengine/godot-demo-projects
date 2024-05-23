extends Node3D

var _is_parent_ready := false
var _cube_points_math: Array[Node3D] = []
var _cube_math_spatials: Array[Node3D] = []

@onready var _cube_point_scene: PackedScene = preload("res://assets/cube/cube_point.tscn")
@onready var _parent: Node = get_parent()


func _ready() -> void:
	_parent = get_parent()

	for i in 27:
		@warning_ignore("integer_division")
		var a: int = (i / 9) - 1
		@warning_ignore("integer_division")
		var b: int = (i / 3) % 3 - 1
		var c: int = (i % 3) - 1
		var spatial_position: Vector3 = 5 * (a * Vector3.RIGHT + b * Vector3.UP + c * Vector3.BACK)
		_cube_math_spatials.append(Node3D.new())
		_cube_math_spatials[i].position = spatial_position
		_cube_math_spatials[i].name = "CubeMath #" + str(i) + ", " + str(a) + " " + str(b) + " " + str(c)
		add_child(_cube_math_spatials[i])


func _process(delta: float) -> void:
	if Input.is_action_pressed(&"exit"):
		get_tree().quit()

	if Input.is_action_just_pressed(&"view_cube_demo"):
		get_tree().change_scene_to_file("res://assets/demo_scene.tscn")
		return

	if _is_parent_ready:
		if Input.is_action_just_pressed(&"reset_position"):
			transform = Transform3D.IDENTITY
		else:
			rotate_x(delta * (Input.get_axis(&"move_forward", &"move_back")))
			rotate_y(delta * (Input.get_axis(&"move_left", &"move_right")))
			rotate_z(delta * (Input.get_axis(&"move_clockwise", &"move_counterclockwise")))
		for i in 27:
			_cube_points_math[i].global_transform = _cube_math_spatials[i].global_transform
	else:
		# This code block will be run only once. It's not in `_ready()` because the parent isn't set up there.
		for i in 27:
			var my_cube_point_scene := _cube_point_scene.duplicate(true)
			var cube_point: Node = my_cube_point_scene.instantiate()
			cube_point.name = "CubePoint #" + str(i)
			_cube_points_math.append(cube_point.get_child(0))
			_parent.add_child(cube_point)
		_is_parent_ready = true
