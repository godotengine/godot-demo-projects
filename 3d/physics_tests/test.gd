class_name Test
extends Node


signal wait_done()

export var _enable_debug_collision = true

var _timer
var _timer_started = false

var _wait_physics_ticks_counter = 0

var _drawn_nodes = []


func _enter_tree():
	if not _enable_debug_collision:
		get_tree().debug_collisions_hint = false


func _physics_process(_delta):
	if _wait_physics_ticks_counter > 0:
		_wait_physics_ticks_counter -= 1
		if _wait_physics_ticks_counter == 0:
			emit_signal("wait_done")


func add_sphere(pos, radius, color):
	var sphere = MeshInstance.new()

	var sphere_mesh = SphereMesh.new()
	sphere_mesh.radius = radius
	sphere_mesh.height = radius * 2.0
	sphere.mesh = sphere_mesh

	var material = SpatialMaterial.new()
	material.flags_unshaded = true
	material.albedo_color = color
	sphere.material_override = material

	_drawn_nodes.push_back(sphere)
	add_child(sphere)

	sphere.global_transform.origin = pos


func add_shape(shape, transform, color):
	var collision = CollisionShape.new()
	collision.shape = shape

	_drawn_nodes.push_back(collision)
	add_child(collision)

	var mesh_instance = collision.get_child(0)
	var material = SpatialMaterial.new()
	material.flags_unshaded = true
	material.albedo_color = color
	mesh_instance.material_override = material

	collision.global_transform = transform


func clear_drawn_nodes():
	for node in _drawn_nodes:
		node.queue_free()
	_drawn_nodes.clear()


func create_rigidbody(shape, pickable = false, transform = Transform.IDENTITY):
	var collision = CollisionShape.new()
	collision.shape = shape
	collision.transform = transform

	var body = RigidBody.new()
	body.add_child(collision)

	if pickable:
		var script = load("res://utils/rigidbody_pick.gd")
		body.set_script(script)

	return body


func create_rigidbody_box(size, pickable = false, transform = Transform.IDENTITY):
	var shape = BoxShape.new()
	shape.extents = 0.5 * size

	return create_rigidbody(shape, pickable, transform)


func start_timer(timeout):
	if _timer == null:
		_timer = Timer.new()
		_timer.one_shot = true
		add_child(_timer)
		_timer.connect("timeout", self, "_on_timer_done")
	else:
		cancel_timer()

	_timer.start(timeout)
	_timer_started = true

	return _timer


func cancel_timer():
	if _timer_started:
		_timer.paused = true
		_timer.emit_signal("timeout")
		_timer.paused = false


func is_timer_canceled():
	return _timer.paused


func wait_for_physics_ticks(tick_count):
	_wait_physics_ticks_counter = tick_count
	return self


func _on_timer_done():
	_timer_started = false
