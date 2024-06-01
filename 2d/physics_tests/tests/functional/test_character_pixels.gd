extends TestCharacter

const OPTION_TEST_CASE_ALL = "Test Cases/TEST ALL (0)"
const OPTION_TEST_CASE_DETECT_FLOOR_NO_SNAP = "Test Cases/Floor detection (Character Body)"
const OPTION_TEST_CASE_DETECT_FLOOR_MOTION_CHANGES = "Test Cases/Floor detection with motion changes (Character Body)"

const MOTION_CHANGES_DIR = Vector2(1.0, 1.0)
const MOTION_CHANGES_SPEEDS: Array[float] = [0.5, 1.0, 2.0, 5.0, 10.0, 20.0, 50.0]

var _test_floor_detection := false
var _test_motion_changes := false
var _floor_detected := false
var _floor_lost := false

var _failed_reason := ""

func _ready() -> void:
	super._ready()

	options.add_menu_item(OPTION_TEST_CASE_ALL)
	options.add_menu_item(OPTION_TEST_CASE_DETECT_FLOOR_NO_SNAP)
	options.add_menu_item(OPTION_TEST_CASE_DETECT_FLOOR_MOTION_CHANGES)


func _physics_process(delta: float) -> void:
	super._physics_process(delta)

	if _moving_body:
		if _moving_body.is_on_floor():
			_floor_detected = true
		elif _floor_detected:
			_floor_lost = true
			if _test_motion_changes:
				Log.print_log("Floor lost.")

		if _test_motion_changes:
			var speed_count := MOTION_CHANGES_SPEEDS.size()
			var speed_index := randi() % speed_count
			var speed := MOTION_CHANGES_SPEEDS[speed_index]
			var velocity := speed * MOTION_CHANGES_DIR
			_moving_body._constant_velocity = velocity
			#Log.print_log("Velocity: %s" % velocity)


func _input(event: InputEvent) -> void:
	super._input(event)

	if event is InputEventKey and not event.pressed:
		if event.keycode == KEY_0:
			await _on_option_selected(OPTION_TEST_CASE_ALL)


func _on_option_selected(option: String) -> void:
	match option:
		OPTION_TEST_CASE_ALL:
			await _test_all()
		OPTION_TEST_CASE_DETECT_FLOOR_NO_SNAP:
			await _start_test_case(option)
			return
		OPTION_TEST_CASE_DETECT_FLOOR_MOTION_CHANGES:
			await _start_test_case(option)
			return

	super._on_option_selected(option)


func _start_test_case(option: String) -> void:
	Log.print_log("* Starting " + option)

	match option:
		OPTION_TEST_CASE_DETECT_FLOOR_NO_SNAP:
			_test_floor_detection = true
			_test_motion_changes = false
			_use_snap = false
			_body_type = BodyType.CHARACTER_BODY
			_start_test()

			await start_timer(1.0).timeout
			if is_timer_canceled():
				return

			_set_result(not _floor_lost)
		OPTION_TEST_CASE_DETECT_FLOOR_MOTION_CHANGES:
			_test_floor_detection = true
			_test_motion_changes = true
			_use_snap = false
			_body_type = BodyType.CHARACTER_BODY
			_start_test()

			await start_timer(4.0).timeout
			if is_timer_canceled():
				_test_motion_changes = false
				return

			_test_motion_changes = false
			_moving_body._constant_velocity = Vector2.ZERO

			_set_result(not _floor_lost)
		_:
			Log.print_error("Invalid test case.")


func _test_all() -> void:
	Log.print_log("* TESTING ALL...")

	# Test floor detection with no snapping.
	await _start_test_case(OPTION_TEST_CASE_DETECT_FLOOR_NO_SNAP)
	if is_timer_canceled():
		return

	# Test floor detection with no snapping.
	# In this test case, motion alternates different speeds.
	await _start_test_case(OPTION_TEST_CASE_DETECT_FLOOR_MOTION_CHANGES)
	if is_timer_canceled():
		return

	Log.print_log("* Done.")


func _set_result(test_passed: bool) -> void:
	var result := ""
	if test_passed:
		result = "PASSED"
	else:
		result = "FAILED"

	if not test_passed and not _failed_reason.is_empty():
		result += _failed_reason
	else:
		result += "."

	Log.print_log("Test %s" % result)


func _start_test() -> void:
	super._start_test()

	_failed_reason = ""

	_floor_detected = false
	_floor_lost = false

	if _test_floor_detection:
		_failed_reason = ": floor was not detected consistently."
		if _test_motion_changes:
			# Always use the same seed for reproducible results.
			seed(123456789)
			_moving_body._gravity_force = 0.0
			_moving_body._motion_speed = 0.0
			_moving_body._jump_force = 0.0
		else:
			_moving_body._initial_velocity = Vector2(30, 0)
		_test_floor_detection = false
	else:
		_test_motion_changes = false
