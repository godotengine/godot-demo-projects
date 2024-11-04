@tool
extends Test

signal all_tests_done()
signal test_done()

const OPTION_OBJECT_TYPE_RIGIDBODY = "Object type/Rigid body (1)"
const OPTION_OBJECT_TYPE_CHARACTER = "Object type/Character body (2)"

const OPTION_TEST_CASE_ALL = "Test Cases/TEST ALL (0)"
const OPTION_TEST_CASE_ALL_RIGID = "Test Cases/All Rigid Body tests"
const OPTION_TEST_CASE_ALL_CHARACTER = "Test Cases/All Character Body tests"
const OPTION_TEST_CASE_ALL_ANGLES_RIGID = "Test Cases/Around the clock (Rigid Body)"
const OPTION_TEST_CASE_ALL_ANGLES_CHARACTER = "Test Cases/Around the clock (Character Body)"
const OPTION_TEST_CASE_MOVING_PLATFORM_RIGID = "Test Cases/Moving Platform (Rigid Body)"
const OPTION_TEST_CASE_MOVING_PLATFORM_CHARACTER = "Test Cases/Moving Platform (Character Body)"

const TEST_ALL_ANGLES_STEP = 15.0
const TEST_ALL_ANGLES_MAX = 344.0

@export_range(64, 256, 0.1) var _platform_size := 128.0:
	set(value):
		if value == _platform_size:
			return
		_platform_size = value
		_update_platform_size(value)

@export_range(0, 360, 0.1) var _platform_angle := 0.0:
	set(value):
		if value == _platform_angle:
			return
		_platform_angle = value
		_update_platform_angle(value)

@export var _platform_speed := 0.0

@export_range(0, 360, 0.1) var _body_angle := 0.0:
	set(value):
		if value == _body_angle:
			return
		_body_angle = value
		_update_rigidbody_angle(value)

@export var _body_velocity := Vector2(400.0, 0.0)
@export var _use_character_body := false

@onready var options: OptionMenu = $Options

var _rigid_body_template: RigidBody2D = null
var _character_body_template: CharacterBody2D = null
var _moving_body: PhysicsBody2D = null

var _platform_template: StaticBody2D = null
var _platform_body: PhysicsBody2D = null
var _platform_velocity := Vector2.ZERO

@onready var _target_area: Area2D = $TargetArea2D

var _contact_detected := false
var _target_entered := false
var _test_passed := false
var _test_step := 0

var _test_all_angles := false
var _lock_controls := false

var _test_canceled := false


func _ready() -> void:
	if not Engine.is_editor_hint():
		options.add_menu_item(OPTION_OBJECT_TYPE_RIGIDBODY, true, not _use_character_body, true)
		options.add_menu_item(OPTION_OBJECT_TYPE_CHARACTER, true, _use_character_body, true)

		options.add_menu_item(OPTION_TEST_CASE_ALL)
		options.add_menu_item(OPTION_TEST_CASE_ALL_RIGID)
		options.add_menu_item(OPTION_TEST_CASE_ALL_CHARACTER)
		options.add_menu_item(OPTION_TEST_CASE_ALL_ANGLES_RIGID)
		options.add_menu_item(OPTION_TEST_CASE_ALL_ANGLES_CHARACTER)
		options.add_menu_item(OPTION_TEST_CASE_MOVING_PLATFORM_RIGID)
		options.add_menu_item(OPTION_TEST_CASE_MOVING_PLATFORM_CHARACTER)

		options.option_selected.connect(_on_option_selected)

		$Controls/PlatformSize/HSlider.value = _platform_size
		$Controls/PlatformAngle/HSlider.value = _platform_angle
		$Controls/BodyAngle/HSlider.value = _body_angle

		remove_child(_target_area)
		_target_area.body_entered.connect(_on_target_entered)
		$Timer.timeout.connect(_on_timeout)

		_rigid_body_template = $RigidBody2D
		remove_child(_rigid_body_template)

		_character_body_template = $CharacterBody2D
		remove_child(_character_body_template)

		_platform_template = $OneWayStaticBody2D
		remove_child(_platform_template)

		_start_test()


func _process(_delta: float) -> void:
	if not Engine.is_editor_hint():
		if Input.is_action_just_pressed(&"ui_accept"):
			await _reset_test(false)


func _physics_process(delta: float) -> void:
	super._physics_process(delta)

	if not Engine.is_editor_hint():
		if _moving_body and not _contact_detected:
			if _use_character_body:
				var collision := _moving_body.move_and_collide(_body_velocity * delta, false)
				if collision:
					var colliding_body := collision.get_collider()
					await _on_contact_detected(colliding_body)

			if _platform_body and _platform_velocity != Vector2.ZERO:
				var motion := _platform_velocity * delta
				_platform_body.global_position += motion


func _input(event: InputEvent) -> void:
	if event is InputEventKey and not event.pressed:
		if event.keycode == KEY_0:
			await _on_option_selected(OPTION_TEST_CASE_ALL)
		if event.keycode == KEY_1:
			await _on_option_selected(OPTION_OBJECT_TYPE_RIGIDBODY)
		elif event.keycode == KEY_2:
			await _on_option_selected(OPTION_OBJECT_TYPE_CHARACTER)


func _exit_tree() -> void:
	if not Engine.is_editor_hint():
		_rigid_body_template.free()
		_character_body_template.free()
		_platform_template.free()


func _update_platform_size(value: float, reset: bool = true) -> void:
	if _lock_controls:
		return
	if value == _platform_size:
		return
	_platform_size = value
	if is_inside_tree():
		if Engine.is_editor_hint():
			$OneWayStaticBody2D/CollisionShape2D.shape.size.x = value
		else:
			var platform_collision := _platform_template.get_child(0)
			platform_collision.shape.size.x = value
			if _platform_body:
				# BUG: Need to re-add when changing shape.
				var child_index := _platform_body.get_index()
				remove_child(_platform_body)
				add_child(_platform_body)
				move_child(_platform_body, child_index)
			if reset:
				await _reset_test()


func _update_platform_angle(value: float, reset: bool = true) -> void:
	if _lock_controls:
		return
	if value == _platform_angle:
		return
	_platform_angle = value
	if is_inside_tree():
		if Engine.is_editor_hint():
			$OneWayStaticBody2D.rotation = deg_to_rad(value)
		else:
			if _platform_body:
				_platform_body.rotation = deg_to_rad(value)
			_platform_template.rotation = deg_to_rad(value)
			if reset:
				await _reset_test()


func _update_rigidbody_angle(value: float, reset: bool = true) -> void:
	if _lock_controls:
		return
	if value == _body_angle:
		return
	_body_angle = value
	if is_inside_tree():
		if Engine.is_editor_hint():
			$RigidBody2D.rotation = deg_to_rad(value)
			$CharacterBody2D.rotation = deg_to_rad(value)
		else:
			if _moving_body:
				_moving_body.rotation = deg_to_rad(value)
			_rigid_body_template.rotation = deg_to_rad(value)
			_character_body_template.rotation = deg_to_rad(value)
			if reset:
				await _reset_test()


func _on_option_selected(option: String) -> void:
	match option:
		OPTION_OBJECT_TYPE_CHARACTER:
			_use_character_body = true
			await _reset_test()
		OPTION_OBJECT_TYPE_RIGIDBODY:
			_use_character_body = false
			await _reset_test()
		OPTION_TEST_CASE_ALL:
			await _test_all()
		OPTION_TEST_CASE_ALL_RIGID:
			await _test_all_rigid_body()
		OPTION_TEST_CASE_ALL_CHARACTER:
			await _test_all_character_body()
		OPTION_TEST_CASE_ALL_ANGLES_RIGID:
			_use_character_body = false
			_test_all_angles = true
			await _reset_test(false)
		OPTION_TEST_CASE_ALL_ANGLES_CHARACTER:
			_use_character_body = true
			_test_all_angles = true
			await _reset_test(false)
		OPTION_TEST_CASE_MOVING_PLATFORM_RIGID:
			_use_character_body = false
			await _test_moving_platform()
		OPTION_TEST_CASE_MOVING_PLATFORM_CHARACTER:
			_use_character_body = true
			await _test_moving_platform()


func _start_test_case(option: String) -> void:
	Log.print_log("* Starting " + option)

	await _on_option_selected(option)

	await all_tests_done


func _wait_for_test() -> void:
	await _reset_test()

	await test_done


func _test_all_rigid_body() -> void:
	Log.print_log("* All RigidBody test cases...")

	await _update_platform_size(128.0, false)
	await _update_rigidbody_angle(0.0, false)
	await _start_test_case(OPTION_TEST_CASE_ALL_ANGLES_RIGID)
	if _test_canceled:
		return

	await _update_platform_size(128.0, false)
	await _update_rigidbody_angle(45.0, false)
	await _start_test_case(OPTION_TEST_CASE_ALL_ANGLES_RIGID)
	if _test_canceled:
		return

	await _update_platform_size(64.0, false)
	await _update_rigidbody_angle(45.0, false)
	await _start_test_case(OPTION_TEST_CASE_ALL_ANGLES_RIGID)
	if _test_canceled:
		return

	await _start_test_case(OPTION_TEST_CASE_MOVING_PLATFORM_RIGID)
	if _test_canceled:
		return


func _test_all_character_body() -> void:
	Log.print_log("* All CharacterBody test cases...")

	await _update_platform_size(128.0, false)
	await _update_rigidbody_angle(0.0, false)
	await _start_test_case(OPTION_TEST_CASE_ALL_ANGLES_CHARACTER)
	if _test_canceled:
		return

	await _update_platform_size(128.0, false)
	await _update_rigidbody_angle(45.0, false)
	await _start_test_case(OPTION_TEST_CASE_ALL_ANGLES_CHARACTER)
	if _test_canceled:
		return

	await _update_platform_size(64.0, false)
	await _update_rigidbody_angle(45.0, false)
	await _start_test_case(OPTION_TEST_CASE_ALL_ANGLES_CHARACTER)
	if _test_canceled:
		return

	await _start_test_case(OPTION_TEST_CASE_MOVING_PLATFORM_CHARACTER)
	if _test_canceled:
		return


func _test_moving_platform() -> void:
	Log.print_log("* Start moving platform tests")

	Log.print_log("* Platform moving away from body...")
	await _update_platform_size(128.0, false)
	await _update_rigidbody_angle(0.0, false)
	_platform_speed = 50.0

	await _update_platform_angle(90.0, false)
	await _wait_for_test()
	if _test_canceled:
		return

	await _update_platform_angle(-90.0, false)
	await _wait_for_test()
	if _test_canceled:
		return

	Log.print_log("* Platform moving towards body...")
	await _update_platform_size(128.0, false)
	await _update_rigidbody_angle(0.0, false)
	_platform_speed = -50.0

	await _update_platform_angle(90.0, false)
	await _wait_for_test()
	if _test_canceled:
		return

	await _update_platform_angle(-90.0, false)
	await _wait_for_test()
	if _test_canceled:
		return

	_platform_speed = 0.0
	all_tests_done.emit()


func _test_all() -> void:
	Log.print_log("* TESTING ALL...")

	await _test_all_rigid_body()
	if _test_canceled:
		return

	await _test_all_character_body()
	if _test_canceled:
		return

	Log.print_log("* Done.")


func _start_test() -> void:
	var test_label := "Testing: "

	var platform_angle := _platform_template.rotation
	if _platform_body:
		platform_angle = _platform_body.rotation
		_platform_body.remove_child(_target_area)
		remove_child(_platform_body)
		_platform_body.queue_free()
		_platform_body = null

	_platform_body = _platform_template.duplicate()
	_platform_body.rotation = platform_angle
	add_child(_platform_body)

	_platform_body.add_child(_target_area)
	_target_area.position = Vector2()

	if _use_character_body:
		test_label += String(_character_body_template.name)
		_moving_body = _character_body_template.duplicate()
	else:
		test_label += String(_rigid_body_template.name)
		_moving_body = _rigid_body_template.duplicate()
		_moving_body.linear_velocity = _body_velocity
		_moving_body.body_entered.connect(_on_contact_detected)
	add_child(_moving_body)

	if _platform_speed != 0.0:
		var platform_pos := _platform_body.global_position
		var body_pos := _moving_body.global_position
		var dir := (platform_pos - body_pos).normalized()
		_platform_velocity = dir * _platform_speed
	else:
		_platform_velocity = Vector2.ZERO

	if _test_all_angles:
		test_label += " - All angles"

	$LabelTestType.text = test_label

	_contact_detected = false
	_target_entered = false
	_test_passed = false
	_test_step += 1

	$Timer.start()

	$LabelResult.text = "..."
	$LabelResult.self_modulate = Color.WHITE


func _reset_test(cancel_test: bool = true) -> void:
	_test_canceled = true
	await _on_timeout()
	_test_canceled = false

	_test_step = 0

	if _test_all_angles:
		if cancel_test:
			Log.print_log("*** Stop around the clock tests")
			_test_all_angles = false
			all_tests_done.emit()
		else:
			Log.print_log("*** Start around the clock tests")
		_platform_body.rotation = deg_to_rad(_platform_angle)
		_lock_controls = true
		$Controls/PlatformAngle/HSlider.value = _platform_angle
		_lock_controls = false

	_next_test(true)


func _next_test(force_start: bool = false) -> void:
	if _moving_body:
		remove_child(_moving_body)
		_moving_body.queue_free()
		_moving_body = null

	if _test_all_angles:
		var angle := rad_to_deg(_platform_body.rotation)
		if angle >= _platform_angle + TEST_ALL_ANGLES_MAX:
			_platform_body.rotation = deg_to_rad(_platform_angle)
			_lock_controls = true
			$Controls/PlatformAngle/HSlider.value = _platform_angle
			_lock_controls = false
			_test_all_angles = false
			Log.print_log("*** Done all angles")
		else:
			angle = _platform_angle + _test_step * TEST_ALL_ANGLES_STEP
			_platform_body.rotation = deg_to_rad(angle)
			_lock_controls = true
			$Controls/PlatformAngle/HSlider.value = angle
			_lock_controls = false
			_start_test()
	elif force_start:
		_start_test()


func _on_contact_detected(_body: PhysicsBody2D) -> void:
	if _contact_detected or _target_entered:
		return

	_contact_detected = true
	_test_passed = _should_collide()
	_set_result()
	await _on_timeout()


func _on_target_entered(_body: PhysicsBody2D) -> void:
	if _body != _moving_body:
		return

	if _contact_detected or _target_entered:
		return

	_target_entered = true
	_test_passed = not _should_collide()
	_set_result()
	await _on_timeout()


func _should_collide() -> bool:
	var platform_rotation := roundf(rad_to_deg(_platform_body.rotation))

	var angle := fposmod(platform_rotation, 360)
	return angle > 180


func _on_timeout() -> void:
	cancel_timer()

	if $Timer.is_stopped():
		return

	$Timer.stop()

	if _test_canceled:
		test_done.emit()
		all_tests_done.emit()
		return

	if not _contact_detected and not _target_entered:
		Log.print_log("Test TIMEOUT")
		_set_result()

	await start_timer(0.5).timeout
	if _test_canceled:
		test_done.emit()
		all_tests_done.emit()
		return

	var was_all_angles := _test_all_angles

	_next_test()

	test_done.emit()

	if was_all_angles and not _test_all_angles:
		all_tests_done.emit()


func _set_result() -> void:
	var result := ""
	if _test_passed:
		result = "PASSED"
		$LabelResult.self_modulate = Color.GREEN
	else:
		result = "FAILED"
		$LabelResult.self_modulate = Color.RED

	$LabelResult.text = result

	var platform_angle := rad_to_deg(_platform_body.rotation)

	result += ": size=%.1f, angle=%.1f, body angle=%.1f" % [_platform_size, platform_angle, _body_angle]
	Log.print_log("Test %s" % result)
