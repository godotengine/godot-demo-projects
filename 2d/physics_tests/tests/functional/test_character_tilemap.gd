extends TestCharacter


const OPTION_TEST_CASE_JUMP_ONE_WAY = "Test Cases/Jump through one-way tiles"

var _test_jump_one_way = false


func _ready():
	$Options.add_menu_item(OPTION_TEST_CASE_JUMP_ONE_WAY, true, false)


func _on_option_changed(option, checked):
	match option:
		OPTION_TEST_CASE_JUMP_ONE_WAY:
			_test_jump_one_way = checked
			_start_test()

	._on_option_changed(option, checked)


func _start_test():
	._start_test()

	if _test_jump_one_way:
		_moving_body._initial_velocity = Vector2(600, -1000)
