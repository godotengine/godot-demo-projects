extends Test
class_name TestCharacter


enum E_BodyType {
	RIGID_BODY,
	KINEMATIC_BODY,
	KINEMATIC_BODY_RAY_SHAPE,
}

const OPTION_OBJECT_TYPE_RIGIDBODY = "Object type/Rigid body (1)"
const OPTION_OBJECT_TYPE_KINEMATIC = "Object type/Kinematic body (2)"
const OPTION_OBJECT_TYPE_KINEMATIC_RAYSHAPE = "Object type/Kinematic body with ray shape (3)"

const OPTION_MOVE_KINEMATIC_SNAP = "Move Options/Use snap (Kinematic only)"
const OPTION_MOVE_KINEMATIC_STOP_ON_SLOPE = "Move Options/Use stop on slope (Kinematic only)"

export(Vector2) var _initial_velocity = Vector2.ZERO
export(Vector2) var _constant_velocity = Vector2.ZERO
export(float) var _motion_speed = 400.0
export(float) var _gravity_force = 50.0
export(float) var _jump_force = 1000.0
export(float) var _snap_distance = 0.0
export(float) var _floor_max_angle = 45.0
export(E_BodyType) var _body_type = 0

onready var options = $Options

var _use_snap = true
var _use_stop_on_slope = true

var _body_parent = null
var _rigid_body_template = null
var _kinematic_body_template = null
var _kinematic_body_ray_template = null
var _moving_body = null


func _ready():
	options.connect("option_selected", self, "_on_option_selected")
	options.connect("option_changed", self, "_on_option_changed")

	_rigid_body_template = find_node("RigidBody2D")
	if _rigid_body_template:
		_body_parent = _rigid_body_template.get_parent()
		_body_parent.remove_child(_rigid_body_template)
		var enabled = _body_type == E_BodyType.RIGID_BODY
		options.add_menu_item(OPTION_OBJECT_TYPE_RIGIDBODY, true, enabled, true)

	_kinematic_body_template = find_node("KinematicBody2D")
	if _kinematic_body_template:
		_body_parent = _kinematic_body_template.get_parent()
		_body_parent.remove_child(_kinematic_body_template)
		var enabled = _body_type == E_BodyType.KINEMATIC_BODY
		options.add_menu_item(OPTION_OBJECT_TYPE_KINEMATIC, true, enabled, true)

	_kinematic_body_ray_template = find_node("KinematicBodyRay2D")
	if _kinematic_body_ray_template:
		_body_parent = _kinematic_body_ray_template.get_parent()
		_body_parent.remove_child(_kinematic_body_ray_template)
		var enabled = _body_type == E_BodyType.KINEMATIC_BODY_RAY_SHAPE
		options.add_menu_item(OPTION_OBJECT_TYPE_KINEMATIC_RAYSHAPE, true, enabled, true)

	options.add_menu_item(OPTION_MOVE_KINEMATIC_SNAP, true, _use_snap)
	options.add_menu_item(OPTION_MOVE_KINEMATIC_STOP_ON_SLOPE, true, _use_stop_on_slope)

	_start_test()


func _process(_delta):
	var label_floor = $LabelFloor
	if _moving_body:
		if _moving_body.is_on_floor():
			label_floor.text = "ON FLOOR"
			label_floor.self_modulate = Color.green
		else:
			label_floor.text = "OFF FLOOR"
			label_floor.self_modulate = Color.red
	else:
		label_floor.visible = false


func _input(event):
	var key_event = event as InputEventKey
	if key_event and not key_event.pressed:
		if key_event.scancode == KEY_1:
			if _rigid_body_template:
				_on_option_selected(OPTION_OBJECT_TYPE_RIGIDBODY)
		elif key_event.scancode == KEY_2:
			if _kinematic_body_template:
				_on_option_selected(OPTION_OBJECT_TYPE_KINEMATIC)
		elif key_event.scancode == KEY_3:
			if _kinematic_body_ray_template:
				_on_option_selected(OPTION_OBJECT_TYPE_KINEMATIC_RAYSHAPE)


func _exit_tree():
	if _rigid_body_template:
		_rigid_body_template.free()
	if _kinematic_body_template:
		_kinematic_body_template.free()
	if _kinematic_body_ray_template:
		_kinematic_body_ray_template.free()


func _on_option_selected(option):
	match option:
		OPTION_OBJECT_TYPE_RIGIDBODY:
			_body_type = E_BodyType.RIGID_BODY
			_start_test()
		OPTION_OBJECT_TYPE_KINEMATIC:
			_body_type = E_BodyType.KINEMATIC_BODY
			_start_test()
		OPTION_OBJECT_TYPE_KINEMATIC_RAYSHAPE:
			_body_type = E_BodyType.KINEMATIC_BODY_RAY_SHAPE
			_start_test()


func _on_option_changed(option, checked):
	match option:
		OPTION_MOVE_KINEMATIC_SNAP:
			_use_snap = checked
			_start_test()
		OPTION_MOVE_KINEMATIC_STOP_ON_SLOPE:
			_use_stop_on_slope = checked
			_start_test()


func _start_test():
	cancel_timer()

	if _moving_body:
		_body_parent.remove_child(_moving_body)
		_moving_body.queue_free()
		_moving_body = null

	var test_label = "Testing: "

	var template = null
	match _body_type:
		E_BodyType.RIGID_BODY:
			template = _rigid_body_template
		E_BodyType.KINEMATIC_BODY:
			template = _kinematic_body_template
		E_BodyType.KINEMATIC_BODY_RAY_SHAPE:
			template = _kinematic_body_ray_template

	test_label += template.name
	_moving_body = template.duplicate()
	_body_parent.add_child(_moving_body)

	_moving_body._initial_velocity = _initial_velocity
	_moving_body._constant_velocity = _constant_velocity

	_moving_body._motion_speed = _motion_speed
	_moving_body._gravity_force = _gravity_force
	_moving_body._jump_force = _jump_force

	if _moving_body is KinematicBody2D:
		if _use_snap:
			_moving_body._snap = Vector2(0, _snap_distance)
		_moving_body._stop_on_slope = _use_stop_on_slope
		_moving_body._floor_max_angle = _floor_max_angle

	$LabelTestType.text = test_label
