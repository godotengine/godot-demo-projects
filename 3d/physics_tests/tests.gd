extends Node


var _tests = [
	{
		"id": "Functional Tests/Shapes",
		"path": "res://tests/functional/test_shapes.tscn",
	},
	{
		"id": "Functional Tests/Compound Shapes",
		"path": "res://tests/functional/test_compound_shapes.tscn",
	},
	{
		"id": "Functional Tests/Friction",
		"path": "res://tests/functional/test_friction.tscn",
	},
	{
		"id": "Performance Tests/Contacts",
		"path": "res://tests/performance/test_perf_contacts.tscn",
	},
]


func _ready():
	var test_menu = $TestsMenu
	for test in _tests:
		test_menu.add_test(test.id, test.path)
