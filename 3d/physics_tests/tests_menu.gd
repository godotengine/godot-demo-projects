extends OptionMenu


class TestData:
	var id
	var scene_path


var _test_list = []

var _current_test = null
var _current_test_scene = null


func _ready():
	connect("option_selected", self, "_on_option_selected")


func _process(_delta):
	if Input.is_action_just_pressed("restart_test"):
		if _current_test:
			_start_test(_current_test)


func add_test(id, scene_path):
	var test_data = TestData.new()
	test_data.id = id
	test_data.scene_path = scene_path
	_test_list.append(test_data)

	add_menu_item(id)


func _on_option_selected(item_path):
	for test in _test_list:
		if test.id == item_path:
			_start_test(test)


func _start_test(test):
	_current_test = test

	if _current_test_scene:
		_current_test_scene.queue_free()
		_current_test_scene = null

	Log.print_log("*** STARTING TEST: " + test.id)
	var scene = load(test.scene_path)
	_current_test_scene = scene.instance()
	get_tree().root.add_child(_current_test_scene)

	var label_test = get_node("../LabelTest")
	label_test.test_name = test.id
