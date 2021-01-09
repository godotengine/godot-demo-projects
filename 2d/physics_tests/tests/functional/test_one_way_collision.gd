extends Test
tool


const OPTION_OBJECT_TYPE_RIGIDBODY = "Object type/Rigid body (1)"
const OPTION_OBJECT_TYPE_KINEMATIC = "Object type/Kinematic body (2)"

const OPTION_TEST_CASE_ALL_ANGLES = "Test case/Around the clock (0)"

const TEST_ALL_ANGLES_STEP = 15.0
const TEST_ALL_ANGLES_MAX = 344.0

export(float, 32, 128, 0.1) var _platform_size = 64.0 setget _set_platform_size
export(float, 0, 360, 0.1) var _platform_angle = 0.0 setget _set_platform_angle
export(float, 0, 360, 0.1) var _body_angle = 0.0 setget _set_rigidbody_angle
export(Vector2) var _body_velocity = Vector2(400.0, 0.0)
export(bool) var _use_kinematic_body = false

var _rigid_body_template = null
var _kinematic_body_template = null
var _moving_body = null

var _contact_detected = false
var _target_entered = false
var _test_passed = false
var _test_step = 0

var _test_all_angles = false
var _lock_controls = false


func _ready():
	if not Engine.editor_hint:
		$Options.add_menu_item(OPTION_OBJECT_TYPE_RIGIDBODY, true, not _use_kinematic_body, true)
		$Options.add_menu_item(OPTION_OBJECT_TYPE_KINEMATIC, true, _use_kinematic_body, true)

		$Options.add_menu_item(OPTION_TEST_CASE_ALL_ANGLES)

		$Options.connect("option_selected", self, "_on_option_selected")

		$Controls/PlatformSize/HSlider.value = _platform_size
		$Controls/PlatformAngle/HSlider.value = _platform_angle
		$Controls/BodyAngle/HSlider.value = _body_angle

		$TargetArea2D.connect("body_entered", self, "_on_target_entered")
		$Timer.connect("timeout", self, "_on_timeout")

		_rigid_body_template = $RigidBody2D
		remove_child(_rigid_body_template)

		_kinematic_body_template = $KinematicBody2D
		remove_child(_kinematic_body_template)

		_start_test()


func _process(_delta):
	if not Engine.editor_hint:
		if Input.is_action_just_pressed("ui_accept"):
			_reset_test(false)


func _physics_process(_delta):
	if not Engine.editor_hint:
		if _moving_body and _use_kinematic_body:
			_moving_body.move_and_slide(_body_velocity)
			if _moving_body.get_slide_count() > 0:
				var colliding_body = _moving_body.get_slide_collision(0).collider
				_on_contact_detected(colliding_body)


func _input(event):
	var key_event = event as InputEventKey
	if key_event and not key_event.pressed:
		if key_event.scancode == KEY_0:
			_on_option_selected(OPTION_TEST_CASE_ALL_ANGLES)
		if key_event.scancode == KEY_1:
			_on_option_selected(OPTION_OBJECT_TYPE_RIGIDBODY)
		elif key_event.scancode == KEY_2:
			_on_option_selected(OPTION_OBJECT_TYPE_KINEMATIC)


func _exit_tree():
	if not Engine.editor_hint:
		_rigid_body_template.free()
		_kinematic_body_template.free()


func _set_platform_size(value):
	if _lock_controls:
		return
	if value == _platform_size:
		return
	_platform_size = value
	if is_inside_tree():
		$OneWayRigidBody2D/CollisionShape2D.shape.extents.x = value

		if not Engine.editor_hint:
			# Bug: need to re-add when changing shape.
			var platform = $OneWayRigidBody2D
			var child_index = platform.get_index()
			remove_child(platform)
			add_child(platform)
			move_child(platform, child_index)

			_reset_test()


func _set_platform_angle(value):
	if _lock_controls:
		return
	if value == _platform_angle:
		return
	_platform_angle = value
	if is_inside_tree():
		$OneWayRigidBody2D.rotation = deg2rad(value)
		if not Engine.editor_hint:
			_reset_test()


func _set_rigidbody_angle(value):
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
			_reset_test()


func _on_option_selected(option):
	match option:
		OPTION_OBJECT_TYPE_KINEMATIC:
			_use_kinematic_body = true
			_reset_test()
		OPTION_OBJECT_TYPE_RIGIDBODY:
			_use_kinematic_body = false
			_reset_test()
		OPTION_TEST_CASE_ALL_ANGLES:
			_test_all_angles = true
			_reset_test(false)


func _start_test():
	var test_label = "Testing: "

	if _use_kinematic_body:
		test_label += _kinematic_body_template.name
		_moving_body = _kinematic_body_template.duplicate()
	else:
		test_label += _rigid_body_template.name
		_moving_body = _rigid_body_template.duplicate()
		_moving_body.linear_velocity = _body_velocity
		_moving_body.connect("body_entered", self, "_on_contact_detected")
	add_child(_moving_body)

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
	$Timer.stop()

	_test_step = 0

	if _test_all_angles:
		if cancel_test:
			Log.print_log("*** Stop around the clock tests")
			_test_all_angles = false
		else:
			Log.print_log("*** Start around the clock tests")
		$OneWayRigidBody2D.rotation = deg2rad(_platform_angle)
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
		var angle = rad2deg($OneWayRigidBody2D.rotation)
		if angle >= _platform_angle + TEST_ALL_ANGLES_MAX:
			$OneWayRigidBody2D.rotation = deg2rad(_platform_angle)
			_lock_controls = true
			$Controls/PlatformAngle/HSlider.value = _platform_angle
			_lock_controls = false
			Log.print_log("*** Done all angles")
		else:
			angle = _platform_angle + _test_step * TEST_ALL_ANGLES_STEP
			$OneWayRigidBody2D.rotation = deg2rad(angle)
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
	var platform_rotation = round(rad2deg($OneWayRigidBody2D.rotation))

	var angle = fposmod(platform_rotation, 360)
	return angle > 180


func _on_timeout():
	if not _contact_detected and not _target_entered:
		Log.print_log("Test TIMEOUT")
		_set_result()

	$Timer.stop()

	yield(get_tree().create_timer(0.5), "timeout")

	_next_test()


func _set_result():
	var result = ""
	if _test_passed:
		result = "PASSED"
		$LabelResult.self_modulate = Color.green
	else:
		result = "FAILED"
		$LabelResult.self_modulate = Color.red

	$LabelResult.text = result

	var platform_angle = rad2deg($OneWayRigidBody2D.rotation)

	result += ": size=%.1f, angle=%.1f, body angle=%.1f" % [_platform_size, platform_angle, _body_angle]
	Log.print_log("Test %s" % result)
