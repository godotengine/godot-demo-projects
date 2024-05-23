class_name Test
extends Node2D

signal wait_done()

@export var _enable_debug_collision := true

var _timer: Timer
var _timer_started := false

var _wait_physics_ticks_counter := 0

class Circle2D:
	extends Node2D
	var center := Vector2()
	var radius := 0.0
	var color := Color()

	func _draw() -> void:
		draw_circle(center, radius, color)

var _drawn_nodes := []

func _enter_tree() -> void:
	if not _enable_debug_collision:
		get_tree().debug_collisions_hint = false


func _physics_process(_delta: float) -> void:
	if _wait_physics_ticks_counter > 0:
		_wait_physics_ticks_counter -= 1
		if _wait_physics_ticks_counter == 0:
			wait_done.emit()


func add_line(pos_start: Vector2, pos_end: Vector2, color: Color) -> void:
	var line := Line2D.new()
	line.points = [pos_start, pos_end]
	line.width = 1.5
	line.default_color = color
	_drawn_nodes.push_back(line)
	add_child(line)


func add_circle(pos: Vector2, radius: float, color: Color) -> void:
	var circle := Circle2D.new()
	circle.center = pos
	circle.radius = radius
	circle.color = color
	_drawn_nodes.push_back(circle)
	add_child(circle)


func add_shape(shape: Shape2D, shape_transform: Transform2D, color: Color) -> void:
	var collision := CollisionShape2D.new()
	collision.shape = shape
	collision.transform = shape_transform
	collision.modulate = color
	_drawn_nodes.push_back(collision)
	add_child(collision)


func clear_drawn_nodes() -> void:
	for node: Node in _drawn_nodes:
		node.queue_free()
	_drawn_nodes.clear()


func create_rigidbody(shape: Shape2D, pickable: bool = false, shape_transform: Transform2D = Transform2D.IDENTITY) -> RigidBody2D:
	var collision := CollisionShape2D.new()
	collision.shape = shape
	collision.transform = shape_transform

	var body := RigidBody2D.new()
	body.add_child(collision)

	if pickable:
		var script := load("res://utils/rigidbody_pick.gd")
		body.set_script(script)

	return body


func create_rigidbody_box(size: Vector2, pickable: bool = false, use_icon: bool = false, shape_transform: Transform2D = Transform2D.IDENTITY) -> RigidBody2D:
	var shape := RectangleShape2D.new()
	shape.size = size

	var body := create_rigidbody(shape, pickable, shape_transform)

	if use_icon:
		var texture := load("res://icon.webp")
		var icon := Sprite2D.new()
		icon.texture = texture
		icon.scale = size / texture.get_size()
		body.add_child(icon)

	return body


func find_node(node_name: String) -> Node:
	var nodes := find_children(node_name)
	if nodes.size() > 0:
		return nodes[0]

	return null


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
	return _timer and _timer.paused


func wait_for_physics_ticks(tick_count: int) -> Test:
	_wait_physics_ticks_counter = tick_count
	return self


func _on_timer_done() -> void:
	_timer_started = false
