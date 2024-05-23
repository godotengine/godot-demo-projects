class_name Test
extends TestCharacter

enum BodyType {
	CHARACTER_BODY,
	CHARACTER_BODY_RAY,
	RIGID_BODY,
	RIGID_BODY_RAY,
}

const OPTION_OBJECT_TYPE_CHARACTER = "Object type/Character body (1)"
const OPTION_OBJECT_TYPE_CHARACTER_RAY = "Object type/Character body with ray (2)"
const OPTION_OBJECT_TYPE_RIGID_BODY = "Object type/Rigid body (3)"
const OPTION_OBJECT_TYPE_RIGID_BODY_RAY = "Object type/Rigid body with ray (4)"

const OPTION_MOVE_CHARACTER_SNAP = "Move Options/Use snap (Character only)"
const OPTION_MOVE_CHARACTER_STOP_ON_SLOPE = "Move Options/Use stop on slope (Character only)"
const OPTION_MOVE_CHARACTER_FLOOR_ONLY = "Move Options/Move on floor only (Character only)"
const OPTION_MOVE_CHARACTER_CONSTANT_SPEED = "Move Options/Use constant speed (Character only)"

@export var _initial_velocity := Vector2.ZERO
@export var _constant_velocity := Vector2.ZERO
@export var _motion_speed := 400.0
@export var _gravity_force := 50.0
@export var _jump_force := 1000.0
@export var _snap_distance := 0.0
@export var _floor_max_angle := 45.0
@export var _body_type := BodyType.CHARACTER_BODY

@onready var options: OptionMenu = $Options

var _use_snap := true
var _use_stop_on_slope := true
var _use_floor_only := true
var _use_constant_speed := false

var _body_parent: Node = null
var _character_body_template: CharacterBody2D = null
var _character_body_ray_template: CharacterBody2D = null
var _rigid_body_template: RigidBody2D = null
var _rigid_body_ray_template: RigidBody2D = null
var _moving_body: PhysicsBody2D = null


func _ready() -> void:
	options.option_selected.connect(_on_option_selected)
	options.option_changed.connect(_on_option_changed)

	_character_body_template = find_child("CharacterBody2D")
	if _character_body_template:
		_body_parent = _character_body_template.get_parent()
		_body_parent.remove_child(_character_body_template)
		var enabled := _body_type == BodyType.CHARACTER_BODY
		options.add_menu_item(OPTION_OBJECT_TYPE_CHARACTER, true, enabled, true)

	_character_body_ray_template = find_child("CharacterBodyRay2D")
	if _character_body_ray_template:
		_body_parent = _character_body_ray_template.get_parent()
		_body_parent.remove_child(_character_body_ray_template)
		var enabled := _body_type == BodyType.CHARACTER_BODY_RAY
		options.add_menu_item(OPTION_OBJECT_TYPE_CHARACTER_RAY, true, enabled, true)

	_rigid_body_template = find_child("RigidBody2D")
	if _rigid_body_template:
		_body_parent = _rigid_body_template.get_parent()
		_body_parent.remove_child(_rigid_body_template)
		var enabled := _body_type == BodyType.RIGID_BODY
		options.add_menu_item(OPTION_OBJECT_TYPE_RIGID_BODY, true, enabled, true)

	_rigid_body_ray_template = find_child("RigidBodyRay2D")
	if _rigid_body_ray_template:
		_body_parent = _rigid_body_ray_template.get_parent()
		_body_parent.remove_child(_rigid_body_ray_template)
		var enabled := _body_type == BodyType.RIGID_BODY_RAY
		options.add_menu_item(OPTION_OBJECT_TYPE_RIGID_BODY_RAY, true, enabled, true)

	options.add_menu_item(OPTION_MOVE_CHARACTER_SNAP, true, _use_snap)
	options.add_menu_item(OPTION_MOVE_CHARACTER_STOP_ON_SLOPE, true, _use_stop_on_slope)
	options.add_menu_item(OPTION_MOVE_CHARACTER_FLOOR_ONLY, true, _use_floor_only)
	options.add_menu_item(OPTION_MOVE_CHARACTER_CONSTANT_SPEED, true, _use_constant_speed)

	var floor_slider: Control = find_child("FloorMaxAngle")
	if floor_slider:
		floor_slider.get_node("HSlider").value = _floor_max_angle

	_start_test()


func _process(_delta: float) -> void:
	var label_floor: Label = $LabelFloor
	if _moving_body:
		if _moving_body.is_on_floor():
			label_floor.text = "ON FLOOR"
			label_floor.self_modulate = Color.GREEN
		else:
			label_floor.text = "OFF FLOOR"
			label_floor.self_modulate = Color.RED
	else:
		label_floor.visible = false


func _input(event: InputEvent) -> void:
	var key_event := event as InputEventKey
	if key_event and not key_event.pressed:
		if key_event.keycode == KEY_1:
			if _character_body_template:
				_on_option_selected(OPTION_OBJECT_TYPE_CHARACTER)
		elif key_event.keycode == KEY_2:
			if _character_body_ray_template:
				_on_option_selected(OPTION_OBJECT_TYPE_CHARACTER_RAY)
		elif key_event.keycode == KEY_3:
			if _rigid_body_template:
				_on_option_selected(OPTION_OBJECT_TYPE_RIGID_BODY)
		elif key_event.keycode == KEY_4:
			if _rigid_body_ray_template:
				_on_option_selected(OPTION_OBJECT_TYPE_RIGID_BODY_RAY)


func _exit_tree() -> void:
	if _character_body_template:
		_character_body_template.free()
	if _character_body_ray_template:
		_character_body_ray_template.free()
	if _rigid_body_template:
		_rigid_body_template.free()
	if _rigid_body_ray_template:
		_rigid_body_ray_template.free()


func _on_option_selected(option: String) -> void:
	match option:
		OPTION_OBJECT_TYPE_CHARACTER:
			_body_type = BodyType.CHARACTER_BODY
			_start_test()
		OPTION_OBJECT_TYPE_CHARACTER_RAY:
			_body_type = BodyType.CHARACTER_BODY_RAY
			_start_test()
		OPTION_OBJECT_TYPE_RIGID_BODY:
			_body_type = BodyType.RIGID_BODY
			_start_test()
		OPTION_OBJECT_TYPE_RIGID_BODY_RAY:
			_body_type = BodyType.RIGID_BODY_RAY
			_start_test()


func _on_option_changed(option: String, checked: bool) -> void:
	match option:
		OPTION_MOVE_CHARACTER_SNAP:
			_use_snap = checked
			if _moving_body and _moving_body is CharacterBody2D:
				_moving_body._snap = _snap_distance if _use_snap else 0.0
		OPTION_MOVE_CHARACTER_STOP_ON_SLOPE:
			_use_stop_on_slope = checked
			if _moving_body and _moving_body is CharacterBody2D:
				_moving_body._stop_on_slope = _use_stop_on_slope
		OPTION_MOVE_CHARACTER_FLOOR_ONLY:
			_use_floor_only = checked
			if _moving_body and _moving_body is CharacterBody2D:
				_moving_body._move_on_floor_only = _use_floor_only
		OPTION_MOVE_CHARACTER_CONSTANT_SPEED:
			_use_constant_speed = checked
			if _moving_body and _moving_body is CharacterBody2D:
				_moving_body._constant_speed = _use_constant_speed


func _update_floor_max_angle(value: float) -> void:
	if value == _floor_max_angle:
		return

	_floor_max_angle = value
	if _moving_body and _moving_body is CharacterBody2D:
		_moving_body._floor_max_angle = _floor_max_angle


func _start_test() -> void:
	cancel_timer()

	if _moving_body:
		_body_parent.remove_child(_moving_body)
		_moving_body.queue_free()
		_moving_body = null

	var test_label := "Testing: "

	var template: PhysicsBody2D = null
	match _body_type:
		BodyType.CHARACTER_BODY:
			template = _character_body_template
		BodyType.CHARACTER_BODY_RAY:
			template = _character_body_ray_template
		BodyType.RIGID_BODY:
			template = _rigid_body_template
		BodyType.RIGID_BODY_RAY:
			template = _rigid_body_ray_template

	_moving_body = template.duplicate()
	_body_parent.add_child(_moving_body)

	_moving_body._initial_velocity = _initial_velocity
	_moving_body._constant_velocity = _constant_velocity

	_moving_body._motion_speed = _motion_speed
	_moving_body._gravity_force = _gravity_force
	_moving_body._jump_force = _jump_force
	_moving_body._floor_max_angle = _floor_max_angle

	if _moving_body is CharacterBody2D:
		_moving_body._snap = _snap_distance if _use_snap else 0.0
		_moving_body._stop_on_slope = _use_stop_on_slope
		_moving_body._move_on_floor_only = _use_floor_only
		_moving_body._constant_speed = _use_constant_speed

	$LabelTestType.text = test_label
