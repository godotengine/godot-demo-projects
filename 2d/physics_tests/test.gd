class_name Test
extends Node2D


signal wait_done()

var _timer
var _timer_started = false

var _wait_physics_ticks_counter = 0


class Line:
	var pos_start
	var pos_end
	var color

var _lines = []


func _physics_process(_delta):
	if (_wait_physics_ticks_counter > 0):
		_wait_physics_ticks_counter -= 1
		if (_wait_physics_ticks_counter == 0):
			emit_signal("wait_done")


func _draw():
	for line in _lines:
		draw_line(line.pos_start, line.pos_end, line.color, 1.5)


func add_line(pos_start, pos_end, color):
	var line = Line.new()
	line.pos_start = pos_start
	line.pos_end = pos_end
	line.color = color
	_lines.push_back(line)
	update()


func clear_lines():
	_lines.clear()
	update()


func create_rigidbody_box(size):
	var template_shape = RectangleShape2D.new()
	template_shape.extents = 0.5 * size

	var template_collision = CollisionShape2D.new()
	template_collision.shape = template_shape

	var template_body = RigidBody2D.new()
	template_body.add_child(template_collision)

	return template_body


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
