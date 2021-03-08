extends TestCharacter


const OPTION_TEST_CASE_ALL = "Test Cases/TEST ALL (0)"
const OPTION_TEST_CASE_JUMP_ONE_WAY_RIGID = "Test Cases/Jump through one-way tiles (Rigid Body)"
const OPTION_TEST_CASE_JUMP_ONE_WAY_KINEMATIC = "Test Cases/Jump through one-way tiles (Kinematic Body)"
const OPTION_TEST_CASE_JUMP_ONE_WAY_CORNER_RIGID = "Test Cases/Jump through one-way corner (Rigid Body)"
const OPTION_TEST_CASE_JUMP_ONE_WAY_CORNER_KINEMATIC = "Test Cases/Jump through one-way corner (Kinematic Body)"
const OPTION_TEST_CASE_FALL_ONE_WAY_KINEMATIC = "Test Cases/Fall and pushed on one-way tiles (Kinematic Body)"

var _test_jump_one_way = false
var _test_jump_one_way_corner = false
var _test_fall_one_way = false

var _extra_body = null

var _failed_reason = ""


func _ready():
	options.add_menu_item(OPTION_TEST_CASE_ALL)
	options.add_menu_item(OPTION_TEST_CASE_JUMP_ONE_WAY_RIGID)
	options.add_menu_item(OPTION_TEST_CASE_JUMP_ONE_WAY_KINEMATIC)
	options.add_menu_item(OPTION_TEST_CASE_JUMP_ONE_WAY_CORNER_RIGID)
	options.add_menu_item(OPTION_TEST_CASE_JUMP_ONE_WAY_CORNER_KINEMATIC)
	options.add_menu_item(OPTION_TEST_CASE_FALL_ONE_WAY_KINEMATIC)


func _input(event):
	var key_event = event as InputEventKey
	if key_event and not key_event.pressed:
		if key_event.scancode == KEY_0:
			_on_option_selected(OPTION_TEST_CASE_ALL)


func _on_option_selected(option):
	match option:
		OPTION_TEST_CASE_ALL:
			_test_all()
		OPTION_TEST_CASE_JUMP_ONE_WAY_RIGID:
			_start_test_case(option)
			return
		OPTION_TEST_CASE_JUMP_ONE_WAY_KINEMATIC:
			_start_test_case(option)
			return
		OPTION_TEST_CASE_JUMP_ONE_WAY_CORNER_RIGID:
			_start_test_case(option)
			return
		OPTION_TEST_CASE_JUMP_ONE_WAY_CORNER_KINEMATIC:
			_start_test_case(option)
			return
		OPTION_TEST_CASE_FALL_ONE_WAY_KINEMATIC:
			_start_test_case(option)
			return

	._on_option_selected(option)


func _start_test_case(option):
	Log.print_log("* Starting " + option)

	match option:
		OPTION_TEST_CASE_JUMP_ONE_WAY_RIGID:
			_body_type = E_BodyType.RIGID_BODY
			_test_jump_one_way_corner = false
			yield(_start_jump_one_way(), "completed")
		OPTION_TEST_CASE_JUMP_ONE_WAY_KINEMATIC:
			_body_type = E_BodyType.KINEMATIC_BODY
			_test_jump_one_way_corner = false
			yield(_start_jump_one_way(), "completed")
		OPTION_TEST_CASE_JUMP_ONE_WAY_CORNER_RIGID:
			_body_type = E_BodyType.RIGID_BODY
			_test_jump_one_way_corner = true
			yield(_start_jump_one_way(), "completed")
		OPTION_TEST_CASE_JUMP_ONE_WAY_CORNER_KINEMATIC:
			_body_type = E_BodyType.KINEMATIC_BODY
			_test_jump_one_way_corner = true
			yield(_start_jump_one_way(), "completed")
		OPTION_TEST_CASE_FALL_ONE_WAY_KINEMATIC:
			_body_type = E_BodyType.KINEMATIC_BODY
			yield(_start_fall_one_way(), "completed")
		_:
			Log.print_error("Invalid test case.")


func _test_all():
	Log.print_log("* TESTING ALL...")

	# RigidBody tests.
	yield(_start_test_case(OPTION_TEST_CASE_JUMP_ONE_WAY_RIGID), "completed")
	if is_timer_canceled():
		return

	yield(_start_test_case(OPTION_TEST_CASE_JUMP_ONE_WAY_CORNER_RIGID), "completed")
	if is_timer_canceled():
		return

	# KinematicBody tests.
	yield(_start_test_case(OPTION_TEST_CASE_JUMP_ONE_WAY_KINEMATIC), "completed")
	if is_timer_canceled():
		return

	yield(_start_test_case(OPTION_TEST_CASE_JUMP_ONE_WAY_CORNER_KINEMATIC), "completed")
	if is_timer_canceled():
		return

	yield(_start_test_case(OPTION_TEST_CASE_FALL_ONE_WAY_KINEMATIC), "completed")
	if is_timer_canceled():
		return

	Log.print_log("* Done.")


func _set_result(test_passed):
	var result = ""
	if test_passed:
		result = "PASSED"
	else:
		result = "FAILED"

	if not test_passed and not _failed_reason.empty():
		result += _failed_reason
	else:
		result += "."

	Log.print_log("Test %s" % result)


func _start_test():
	if _extra_body:
		_body_parent.remove_child(_extra_body)
		_extra_body.queue_free()
		_extra_body = null

	._start_test()

	if _test_jump_one_way:
		_test_jump_one_way = false
		_moving_body._initial_velocity = Vector2(600, -1000)

		if _test_jump_one_way_corner:
			_moving_body.position.x = 147.0

		$JumpTargetArea2D.visible = true
		$JumpTargetArea2D/CollisionShape2D.disabled = false

	if _test_fall_one_way:
		_test_fall_one_way = false

		_moving_body.position.y = 350.0
		_moving_body._gravity_force = 100.0
		_moving_body._motion_speed = 0.0
		_moving_body._jump_force = 0.0

		_extra_body = _moving_body.duplicate()
		_extra_body._gravity_force = 100.0
		_extra_body._motion_speed = 0.0
		_extra_body._jump_force = 0.0
		_extra_body.position -= Vector2(0.0, 200.0)
		_body_parent.add_child(_extra_body)

		$FallTargetArea2D.visible = true
		$FallTargetArea2D/CollisionShape2D.disabled = false


func _start_jump_one_way():
	_test_jump_one_way = true
	_start_test()

	yield(start_timer(1.5), "timeout")
	if is_timer_canceled():
		return

	_finalize_jump_one_way()


func _start_fall_one_way():
	_test_fall_one_way = true
	_start_test()

	yield(start_timer(1.0), "timeout")
	if is_timer_canceled():
		return

	_finalize_fall_one_way()


func _finalize_jump_one_way():
	var passed = true
	if not $JumpTargetArea2D.overlaps_body(_moving_body):
		passed = false
		_failed_reason = ": the body wasn't able to jump all the way through."

	_set_result(passed)

	$JumpTargetArea2D.visible = false
	$JumpTargetArea2D/CollisionShape2D.disabled = true


func _finalize_fall_one_way():
	var passed = true
	if $FallTargetArea2D.overlaps_body(_moving_body):
		passed = false
		_failed_reason = ": the body was pushed through the one-way collision."

	_set_result(passed)

	$FallTargetArea2D.visible = false
	$FallTargetArea2D/CollisionShape2D.disabled = true
