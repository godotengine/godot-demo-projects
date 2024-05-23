class_name Test
extends Node

signal wait_done()

@export var _enable_debug_collision := true

var _timer: Timer
var _timer_started := false

var _wait_physics_ticks_counter := 0

var _drawn_nodes: Array[Node3D] = []

func _enter_tree() -> void:
	if not _enable_debug_collision:
		get_tree().debug_collisions_hint = false


func _physics_process(_delta: float) -> void:
	if _wait_physics_ticks_counter > 0:
		_wait_physics_ticks_counter -= 1
		if _wait_physics_ticks_counter == 0:
			wait_done.emit()


func add_sphere(pos: Vector3, radius: float, color: Color) -> void:
	var sphere := MeshInstance3D.new()

	var sphere_mesh := SphereMesh.new()
	sphere_mesh.radius = radius
	sphere_mesh.height = radius * 2.0
	sphere.mesh = sphere_mesh

	var material := StandardMaterial3D.new()
	material.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	material.albedo_color = color
	sphere.set_surface_override_material(0, material)

	_drawn_nodes.push_back(sphere)
	add_child(sphere)

	sphere.global_transform.origin = pos


func add_shape(shape: Shape3D, transform: Transform3D, color: Color) -> void:
	var debug_mesh := shape.get_debug_mesh()

	var mesh_instance := MeshInstance3D.new()
	mesh_instance.transform = transform
	mesh_instance.mesh = debug_mesh

	var material := StandardMaterial3D.new()
	material.flags_unshaded = true
	material.albedo_color = color
	mesh_instance.set_surface_override_material(0, material)

	add_child(mesh_instance)
	_drawn_nodes.push_back(mesh_instance)


func clear_drawn_nodes() -> void:
	for node in _drawn_nodes:
		remove_child(node)
		node.queue_free()

	_drawn_nodes.clear()


func create_rigidbody(shape: Shape3D, pickable: bool = false, transform: Transform3D = Transform3D.IDENTITY) -> RigidBody3D:
	var collision := CollisionShape3D.new()
	collision.shape = shape
	collision.transform = transform

	var body := RigidBody3D.new()
	body.add_child(collision)

	if pickable:
		var script := load("res://utils/rigidbody_pick.gd")
		body.set_script(script)

	return body


func create_rigidbody_box(size: Vector3, pickable: bool = false, transform: Transform3D = Transform3D.IDENTITY) -> RigidBody3D:
	var shape := BoxShape3D.new()
	shape.size = size

	return create_rigidbody(shape, pickable, transform)


func start_timer(timeout: float) -> Timer:
	if _timer == null:
		_timer = Timer.new()
		_timer.one_shot = true
		add_child(_timer)
		_timer.timeout.connect(_on_timer_done)
	else:
		cancel_timer()

	_timer.start(timeout)
	_timer_started = true

	return _timer


func cancel_timer() -> void:
	if _timer_started:
		_timer.paused = true
		_timer.timeout.emit()
		_timer.paused = false


func is_timer_canceled() -> bool:
	return _timer.paused


func wait_for_physics_ticks(tick_count: int) -> Test:
	_wait_physics_ticks_counter = tick_count
	return self


func _on_timer_done() -> void:
	_timer_started = false
