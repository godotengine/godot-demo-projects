class_name Test
extends Node2D


signal wait_done()

export var _enable_debug_collision = true

var _timer
var _timer_started = false

var _wait_physics_ticks_counter = 0

class Circle2D:
	extends Node2D
	var center
	var radius
	var color

	func _draw():
		draw_circle(center, radius, color)

var _drawn_nodes = []


func _enter_tree():
	if not _enable_debug_collision:
		get_tree().debug_collisions_hint = false


func _physics_process(_delta):
	if _wait_physics_ticks_counter > 0:
		_wait_physics_ticks_counter -= 1
		if _wait_physics_ticks_counter == 0:
			emit_signal("wait_done")


func add_line(pos_start, pos_end, color):
	var line = Line2D.new()
	line.points = [pos_start, pos_end]
	line.width = 1.5
	line.default_color = color
	_drawn_nodes.push_back(line)
	add_child(line)


func add_circle(pos, radius, color):
	var circle = Circle2D.new()
	circle.center = pos
	circle.radius = radius
	circle.color = color
	_drawn_nodes.push_back(circle)
	add_child(circle)


func add_shape(shape, transform, color):
	var collision = CollisionShape2D.new()
	collision.shape = shape
	collision.transform = transform
	collision.modulate = color
	_drawn_nodes.push_back(collision)
	add_child(collision)


func clear_drawn_nodes():
	for node in _drawn_nodes:
		node.queue_free()
	_drawn_nodes.clear()


func create_rigidbody(shape, pickable = false, transform = Transform.IDENTITY):
	var collision = CollisionShape2D.new()
	collision.shape = shape
	collision.transform = transform

	var body = RigidBody2D.new()
	body.add_child(collision)

	if pickable:
		var script = load("res://utils/rigidbody_pick.gd")
		body.set_script(script)

	return body


func create_rigidbody_collision(collision, pickable = false, transform = Transform.IDENTITY):
	var collision_copy = collision.duplicate()
	collision_copy.transform = transform

	if collision is CollisionShape2D:
		collision_copy.shape = collision.shape.duplicate()

	var body = RigidBody2D.new()
	body.add_child(collision_copy)

	if pickable:
		var script = load("res://utils/rigidbody_pick.gd")
		body.set_script(script)

	return body


func create_rigidbody_box(size, pickable = false, use_icon = false, transform = Transform.IDENTITY):
	var shape = RectangleShape2D.new()
	shape.extents = 0.5 * size

	var body = create_rigidbody(shape, pickable, transform)

	if use_icon:
		var texture = load("res://icon.png")
		var icon = Sprite.new()
		icon.texture = texture
		icon.scale = size / texture.get_size()
		body.add_child(icon)

	return body


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
	return _timer and _timer.paused


func wait_for_physics_ticks(tick_count):
	_wait_physics_ticks_counter = tick_count
	return self


func _on_timer_done():
	_timer_started = false
