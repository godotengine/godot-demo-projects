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
		"id": "Functional Tests/Box Stack",
		"path": "res://tests/functional/test_stack.tscn",
	},
	{
		"id": "Functional Tests/Box Pyramid",
		"path": "res://tests/functional/test_pyramid.tscn",
	},
	{
		"id": "Functional Tests/Collision Pairs",
		"path": "res://tests/functional/test_collision_pairs.tscn",
	},
	{
		"id": "Functional Tests/Joints",
		"path": "res://tests/functional/test_joints.tscn",
	},
	{
		"id": "Functional Tests/Raycasting",
		"path": "res://tests/functional/test_raycasting.tscn",
	},
	{
		"id": "Performance Tests/Broadphase",
		"path": "res://tests/performance/test_perf_broadphase.tscn",
	},
	{
		"id": "Performance Tests/Contacts",
		"path": "res://tests/performance/test_perf_contacts.tscn",
	},
	{
		"id" : "Performance Tests/Contacts Extended",
		"path" : "res://tests/performance/test_perf_contacts_extended.tscn",
	},
]


func _ready():
	var test_menu = $TestsMenu
	for test in _tests:
		test_menu.add_test(test.id, test.path)
