extends Test
tool


signal all_tests_done()
signal test_done()

const OPTION_OBJECT_TYPE_RIGIDBODY = "Object type/Rigid body (1)"
const OPTION_OBJECT_TYPE_KINEMATIC = "Object type/Kinematic body (2)"

const OPTION_TEST_CASE_ALL = "Test Cases/TEST ALL (0)"
const OPTION_TEST_CASE_ALL_RIGID = "Test Cases/All Rigid Body tests"
const OPTION_TEST_CASE_ALL_KINEMATIC = "Test Cases/All Kinematic Body tests"
const OPTION_TEST_CASE_ALL_ANGLES_RIGID = "Test Cases/Around the clock (Rigid Body)"
const OPTION_TEST_CASE_ALL_ANGLES_KINEMATIC = "Test Cases/Around the clock (Kinematic Body)"
const OPTION_TEST_CASE_MOVING_PLATFORM_RIGID = "Test Cases/Moving Platform (Rigid Body)"
const OPTION_TEST_CASE_MOVING_PLATFORM_KINEMATIC = "Test Cases/Moving Platform (Kinematic Body)"

const TEST_ALL_ANGLES_STEP = 15.0
const TEST_ALL_ANGLES_MAX = 344.0

export(float, 32, 128, 0.1) var _platform_size = 64.0 setget _set_platform_size
export(float, 0, 360, 0.1) var _platform_angle = 0.0 setget _set_platform_angle
export(float) var _platform_speed = 0.0
export(float, 0, 360, 0.1) var _body_angle = 0.0 setget _set_rigidbody_angle
export(Vector2) var _body_velocity = Vector2(400.0, 0.0)
export(bool) var _use_kinematic_body = false

onready var options = $Options

var _rigid_body_template = null
var _kinematic_body_template = null
var _moving_body = null

var _platform_template = null
var _platform_body = null
var _platform_velocity = Vector2.ZERO

var _contact_detected = false
var _target_entered = false
var _test_passed = false
var _test_step = 0

var _test_all_angles = false
var _lock_controls = false

var _test_canceled = false


func _ready():
	if not Engine.editor_hint:
		options.add_menu_item(OPTION_OBJECT_TYPE_RIGIDBODY, true, not _use_kinematic_body, true)
		options.add_menu_item(OPTION_OBJECT_TYPE_KINEMATIC, true, _use_kinematic_body, true)

		options.add_menu_item(OPTION_TEST_CASE_ALL)
		options.add_menu_item(OPTION_TEST_CASE_ALL_RIGID)
		options.add_menu_item(OPTION_TEST_CASE_ALL_KINEMATIC)
		options.add_menu_item(OPTION_TEST_CASE_ALL_ANGLES_RIGID)
		options.add_menu_item(OPTION_TEST_CASE_ALL_ANGLES_KINEMATIC)
		options.add_menu_item(OPTION_TEST_CASE_MOVING_PLATFORM_RIGID)
		options.add_menu_item(OPTION_TEST_CASE_MOVING_PLATFORM_KINEMATIC)

		options.connect("option_selected", self, "_on_option_selected")

		$Controls/PlatformSize/HSlider.value = _platform_size
		$Controls/PlatformAngle/HSlider.value = _platform_angle
		$Controls/BodyAngle/HSlider.value = _body_angle

		$TargetArea2D.connect("body_entered", self, "_on_target_entered")
		$Timer.connect("timeout", self, "_on_timeout")

		_rigid_body_template = $RigidBody2D
		remove_child(_rigid_body_template)

		_kinematic_body_template = $KinematicBody2D
		remove_child(_kinematic_body_template)

		_platform_template = $OneWayKinematicBody2D
		remove_child(_platform_template)

		_start_test()


func _process(_delta):
	if not Engine.editor_hint:
		if Input.is_action_just_pressed("ui_accept"):
			_reset_test(false)


func _physics_process(delta):
	if not Engine.editor_hint:
		if _moving_body and not _contact_detected:
			if _use_kinematic_body:
				var collision = _moving_body.move_and_collide(_body_velocity * delta, false)
				if collision:
					var colliding_body = collision.collider
					_on_contact_detected(colliding_body)

			if _platform_body and _platform_velocity != Vector2.ZERO:
				var motion = _platform_velocity * delta
				_platform_body.global_position += motion


func _input(event):
	var key_event = event as InputEventKey
	if key_event and not key_event.pressed:
		if key_event.scancode == KEY_0:
			_on_option_selected(OPTION_TEST_CASE_ALL)
		if key_event.scancode == KEY_1:
			_on_option_selected(OPTION_OBJECT_TYPE_RIGIDBODY)
		elif key_event.scancode == KEY_2:
			_on_option_selected(OPTION_OBJECT_TYPE_KINEMATIC)


func _exit_tree():
	if not Engine.editor_hint:
		_rigid_body_template.free()
		_kinematic_body_template.free()
		_platform_template.free()


func _set_platform_size(value, reset = true):
	if _lock_controls:
		return
	if value == _platform_size:
		return
	_platform_size = value
	if is_inside_tree():
		if Engine.editor_hint:
			$OneWayKinematicBody2D/CollisionShape2D.shape.extents.x = value
		else:
			var platform_collision = _platform_template.get_child(0)
			platform_collision.shape.extents.x = value
			if _platform_body:
				# Bug: need to re-add when changing shape.
				var child_index = _platform_body.get_index()
				remove_child(_platform_body)
				add_child(_platform_body)
				move_child(_platform_body, child_index)
			if reset:
				_reset_test()


func _set_platform_angle(value, reset = true):
	if _lock_controls:
		return
	if value == _platform_angle:
		return
	_platform_angle = value
	if is_inside_tree():
		if Engine.editor_hint:
			$OneWayKinematicBody2D.rotation = deg2rad(value)
		else:
			if _platform_body:
				_platform_body.rotation = deg2rad(value)
			_platform_template.rotation = deg2rad(value)
			if reset:
				_reset_test()


func _set_rigidbody_angle(value, reset = true):
	if _lock_controls:
		return
	if value == _body_angle:
		return
	_body_angle = value
	if is_inside_tree():
		if Engine.editor_hint:
			$RigidBody2D.rotation = deg2rad(value)
			$KinematicBody2D.rotation = deg2rad(value)
		else:
			if _moving_body:
				_moving_body.rotation = deg2rad(value)
			_rigid_body_template.rotation = deg2rad(value)
			_kinematic_body_template.rotation = deg2rad(value)
			if reset:
				_reset_test()


func _on_option_selected(option):
	match option:
		OPTION_OBJECT_TYPE_KINEMATIC:
			_use_kinematic_body = true
			_reset_test()
		OPTION_OBJECT_TYPE_RIGIDBODY:
			_use_kinematic_body = false
			_reset_test()
		OPTION_TEST_CASE_ALL:
			_test_all()
		OPTION_TEST_CASE_ALL_RIGID:
			_test_all_rigid_body()
		OPTION_TEST_CASE_ALL_KINEMATIC:
			_test_all_kinematic_body()
		OPTION_TEST_CASE_ALL_ANGLES_RIGID:
			_use_kinematic_body = false
			_test_all_angles = true
			_reset_test(false)
		OPTION_TEST_CASE_ALL_ANGLES_KINEMATIC:
			_use_kinematic_body = true
			_test_all_angles = true
			_reset_test(false)
		OPTION_TEST_CASE_MOVING_PLATFORM_RIGID:
			_use_kinematic_body = false
			_test_moving_platform()
		OPTION_TEST_CASE_MOVING_PLATFORM_KINEMATIC:
			_use_kinematic_body = true
			_test_moving_platform()


func _start_test_case(option):
	Log.print_log("* Starting " + option)

	_on_option_selected(option)

	yield(self, "all_tests_done")


func _wait_for_test():
	_reset_test()

	yield(self, "test_done")


func _test_all_rigid_body():
	Log.print_log("* All RigidBody test cases...")

	_set_platform_size(64.0, false)
	_set_rigidbody_angle(0.0, false)
	yield(_start_test_case(OPTION_TEST_CASE_ALL_ANGLES_RIGID), "completed")
	if _test_canceled:
		return

	_set_platform_size(64.0, false)
	_set_rigidbody_angle(45.0, false)
	yield(_start_test_case(OPTION_TEST_CASE_ALL_ANGLES_RIGID), "completed")
	if _test_canceled:
		return

	_set_platform_size(32.0, false)
	_set_rigidbody_angle(45.0, false)
	yield(_start_test_case(OPTION_TEST_CASE_ALL_ANGLES_RIGID), "completed")
	if _test_canceled:
		return

	yield(_start_test_case(OPTION_TEST_CASE_MOVING_PLATFORM_RIGID), "completed")
	if _test_canceled:
		return


func _test_all_kinematic_body():
	Log.print_log("* All KinematicBody test cases...")

	_set_platform_size(64.0, false)
	_set_rigidbody_angle(0.0, false)
	yield(_start_test_case(OPTION_TEST_CASE_ALL_ANGLES_KINEMATIC), "completed")
	if _test_canceled:
		return

	_set_platform_size(64.0, false)
	_set_rigidbody_angle(45.0, false)
	yield(_start_test_case(OPTION_TEST_CASE_ALL_ANGLES_KINEMATIC), "completed")
	if _test_canceled:
		return

	_set_platform_size(32.0, false)
	_set_rigidbody_angle(45.0, false)
	yield(_start_test_case(OPTION_TEST_CASE_ALL_ANGLES_KINEMATIC), "completed")
	if _test_canceled:
		return

	yield(_start_test_case(OPTION_TEST_CASE_MOVING_PLATFORM_KINEMATIC), "completed")
	if _test_canceled:
		return


func _test_moving_platform():
	Log.print_log("* Start moving platform tests")

	Log.print_log("* Platform moving away from body...")
	_set_platform_size(64.0, false)
	_set_rigidbody_angle(0.0, false)
	_platform_speed = 50.0

	_set_platform_angle(90.0, false)
	yield(_wait_for_test(), "completed")
	if _test_canceled:
		return

	_set_platform_angle(-90.0, false)
	yield(_wait_for_test(), "completed")
	if _test_canceled:
		return

	Log.print_log("* Platform moving towards body...")
	_set_platform_size(64.0, false)
	_set_rigidbody_angle(0.0, false)
	_platform_speed = -50.0

	_set_platform_angle(90.0, false)
	yield(_wait_for_test(), "completed")
	if _test_canceled:
		return

	_set_platform_angle(-90.0, false)
	yield(_wait_for_test(), "completed")
	if _test_canceled:
		return

	_platform_speed = 0.0
	emit_signal("all_tests_done")


func _test_all():
	Log.print_log("* TESTING ALL...")

	yield(_test_all_rigid_body(), "completed")
	if _test_canceled:
		return

	yield(_test_all_kinematic_body(), "completed")
	if _test_canceled:
		return

	Log.print_log("* Done.")


func _start_test():
	var test_label = "Testing: "

	var platform_angle = _platform_template.rotation
	if _platform_body:
		platform_angle = _platform_body.rotation
		remove_child(_platform_body)
		_platform_body.queue_free()
		_platform_body = null

	_platform_body = _platform_template.duplicate()
	_platform_body.rotation = platform_angle
	add_child(_platform_body)

	if _use_kinematic_body:
		test_label += _kinematic_body_template.name
		_moving_body = _kinematic_body_template.duplicate()
	else:
		test_label += _rigid_body_template.name
		_moving_body = _rigid_body_template.duplicate()
		_moving_body.linear_velocity = _body_velocity
		_moving_body.connect("body_entered", self, "_on_contact_detected")
	add_child(_moving_body)

	if _platform_speed != 0.0:
		var platform_pos = _platform_body.global_position
		var body_pos = _moving_body.global_position
		var dir = (platform_pos - body_pos).normalized()
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
	$LabelResult.self_modulate = Color.white


func _reset_test(cancel_test = true):
	_test_canceled = true
	_on_timeout()
	_test_canceled = false

	_test_step = 0

	if _test_all_angles:
		if cancel_test:
			Log.print_log("*** Stop around the clock tests")
			_test_all_angles = false
			emit_signal("all_tests_done")
		else:
			Log.print_log("*** Start around the clock tests")
		_platform_body.rotation = deg2rad(_platform_angle)
		_lock_controls = true
		$Controls/PlatformAngle/HSlider.value = _platform_angle
		_lock_controls = false

	_next_test(true)


func _next_test(force_start = false):
	if _moving_body:
		remove_child(_moving_body)
		_moving_body.queue_free()
		_moving_body = null

	if _test_all_angles:
		var angle = rad2deg(_platform_body.rotation)
		if angle >= _platform_angle + TEST_ALL_ANGLES_MAX:
			_platform_body.rotation = deg2rad(_platform_angle)
			_lock_controls = true
			$Controls/PlatformAngle/HSlider.value = _platform_angle
			_lock_controls = false
			_test_all_angles = false
			Log.print_log("*** Done all angles")
		else:
			angle = _platform_angle + _test_step * TEST_ALL_ANGLES_STEP
			_platform_body.rotation = deg2rad(angle)
			_lock_controls = true
			$Controls/PlatformAngle/HSlider.value = angle
			_lock_controls = false
			_start_test()
	elif force_start:
		_start_test()


func _on_contact_detected(_body):
	if _contact_detected or _target_entered:
		return

	_contact_detected = true
	_test_passed = _should_collide()
	_set_result()
	_on_timeout()


func _on_target_entered(_body):
	if _contact_detected or _target_entered:
		return

	_target_entered = true
	_test_passed = not _should_collide()
	_set_result()
	_on_timeout()


func _should_collide():
	var platform_rotation = round(rad2deg(_platform_body.rotation))

	var angle = fposmod(platform_rotation, 360)
	return angle > 180


func _on_timeout():
	cancel_timer()

	if $Timer.is_stopped():
		return

	$Timer.stop()

	if _test_canceled:
		emit_signal("test_done")
		emit_signal("all_tests_done")
		return

	if not _contact_detected and not _target_entered:
		Log.print_log("Test TIMEOUT")
		_set_result()

	yield(start_timer(0.5), "timeout")
	if _test_canceled:
		emit_signal("test_done")
		emit_signal("all_tests_done")
		return

	var was_all_angles = _test_all_angles

	_next_test()

	emit_signal("test_done")

	if was_all_angles and not _test_all_angles:
		emit_signal("all_tests_done")


func _set_result():
	var result = ""
	if _test_passed:
		result = "PASSED"
		$LabelResult.self_modulate = Color.green
	else:
		result = "FAILED"
		$LabelResult.self_modulate = Color.red

	$LabelResult.text = result

	var platform_angle = rad2deg(_platform_body.rotation)

	result += ": size=%.1f, angle=%.1f, body angle=%.1f" % [_platform_size, platform_angle, _body_angle]
	Log.print_log("Test %s" % result)
