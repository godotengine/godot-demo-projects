extends Node

var _tests: Array[Dictionary] = [
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
		"id": "Functional Tests/RigidBody Impact",
		"path": "res://tests/functional/test_rigidbody_impact.tscn",
	},
	{
		"id": "Functional Tests/RigidBody Ground Check",
		"path": "res://tests/functional/test_rigidbody_ground_check.tscn",
	},
	{
		"id": "Functional Tests/Moving Platform",
		"path": "res://tests/functional/test_moving_platform.tscn",
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
		"id": "Performance Tests/Contact Islands",
		"path": "res://tests/performance/test_perf_contact_islands.tscn",
	},
]


func _ready() -> void:
	var test_menu: OptionMenu = $TestsMenu
	for test in _tests:
		test_menu.add_test(test.id, test.path)
