extends Node2D

@export var plot_size := Vector2(180, 2)

@onready var wing := $Wing as VehicleWing3D
@onready var flap := $VBoxContainer/Flap as HSlider
@onready var forward := $VBoxContainer/Forward as CheckBox
@onready var backward := $VBoxContainer/Backward as CheckBox


func _ready() -> void:
	flap.value_changed.connect(func(_v): queue_redraw())
	forward.toggled.connect(func(_v): queue_redraw())
	backward.toggled.connect(func(_v): queue_redraw())


func _draw() -> void:
	_draw_axis()
	var lift: Array[Vector2]
	var drag: Array[Vector2]
	var torque: Array[Vector2]
	if forward.button_pressed:
		_make_plots(true, lift, drag, torque)
		_draw_plots(lift, drag, torque)
	if backward.button_pressed:
		_make_plots(false, lift, drag, torque)
		_draw_plots(lift, drag, torque)


func _draw_plots(lift: Array[Vector2], drag: Array[Vector2], torque: Array[Vector2]) -> void:
	for i in len(lift) - 1:
		draw_line(lift[i], lift[i + 1], Color.RED)
		draw_line(drag[i], drag[i + 1], Color.GREEN)
		draw_line(torque[i], torque[i + 1], Color.YELLOW)


func _make_plots(forward_direction: bool, lift: Array[Vector2], drag: Array[Vector2], torque: Array[Vector2]) -> void:
	lift.clear()
	drag.clear()
	torque.clear()
	var d := 1.0 if forward_direction else - 1.0
	var x := -plot_size.x if forward_direction else plot_size.x
	while true:
		_add_plot_point(x, lift, drag, torque)
		x += d
		if forward_direction && x > plot_size.x:
			break
		elif not forward_direction && x < -plot_size.x:
			break


func _add_plot_point(x: float, lift: Array[Vector2], drag: Array[Vector2], torque: Array[Vector2]) -> void:
	var linear_velocity := Vector3.FORWARD * wing.chord * 2
	var to_factor := 2.0 / (wing.span * wing.get_mac() * wing.density * linear_velocity.length_squared())
	wing.rotation_degrees.x = x
	wing.flap_value = flap.value
	for i in 4:
		wing.calculate(linear_velocity, Vector3.ZERO, wing.position)
	var force :=  wing.get_force()
	lift.append(_to_viewport(Vector2(x, force.y * to_factor)))
	drag.append(_to_viewport(Vector2(x, force.z * to_factor)))
	torque.append(_to_viewport(Vector2(x, wing.get_torque().x * to_factor)))


func _draw_plot_segment(x: float, x2: float) -> void:
	var linear_velocity := Vector3.FORWARD
	var to_factor := 2.0 / (wing.span * wing.get_mac() * wing.density)
	wing.rotation_degrees.x = x
	wing.calculate(linear_velocity, Vector3.ZERO, Vector3.ZERO)
	var force := wing.get_force() * to_factor
	var torque := wing.get_torque() * to_factor
	var lift1 := _to_viewport(Vector2(x, force.y))
	var drag1 := _to_viewport(Vector2(x, force.z))
	var torque1 := _to_viewport(Vector2(x, torque.x))
	wing.rotation_degrees.x = x2
	wing.calculate(linear_velocity, Vector3.ZERO, Vector3.ZERO)
	force = wing.get_force() * to_factor
	torque = wing.get_torque() * to_factor
	var lift2 := _to_viewport(Vector2(x2, force.y))
	var drag2 := _to_viewport(Vector2(x2, force.z))
	var torque2 := _to_viewport(Vector2(x2, torque.x))
	draw_line(lift1, lift2, Color.RED)
	draw_line(drag1, drag2, Color.GREEN)
	draw_line(torque1, torque2, Color.YELLOW)



func _draw_axis() -> void:
	draw_line(_to_viewport(Vector2(-plot_size.x, 0)), _to_viewport(Vector2(plot_size.x, 0)), Color.BLUE)
	draw_line(_to_viewport(Vector2(0, -plot_size.y)), _to_viewport(Vector2(0, plot_size.x)), Color.BLUE)
	var d := 5
	for x in int(plot_size.x):
		var point := _to_viewport(Vector2(x, 0))
		draw_line(point + Vector2(0, -d), point + Vector2(0, d), Color.VIOLET)
		point = _to_viewport(Vector2(-x, 0))
		draw_line(point + Vector2(0, -d), point + Vector2(0, d), Color.VIOLET)

	for i in 20:
		var y := i * plot_size.y / 20
		var point := _to_viewport(Vector2(0, y))
		draw_line(point + Vector2(-d, 0), point + Vector2(d, 0), Color.VIOLET)
		point = _to_viewport(Vector2(0, -y))
		draw_line(point + Vector2(-d, 0), point + Vector2(d, 0), Color.VIOLET)


func _to_viewport(plot_point: Vector2) -> Vector2:
	var rect := get_viewport_rect()
	var center := rect.get_center()
	var size := Vector2(rect.size.x / plot_size.x / 2, rect.size.y / plot_size.y / 2)
	var point := center + plot_point * size
	point.y = center.y - plot_point.y * size.y
	return point
