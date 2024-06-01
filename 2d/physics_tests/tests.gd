extends Node

var _tests := [
	{
		"id": "Functional Tests/Shapes",
		"path": "res://tests/functional/test_shapes.tscn",
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
		"id": "Functional Tests/Character - Slopes",
		"path": "res://tests/functional/test_character_slopes.tscn",
	},
	{
		"id": "Functional Tests/Character - Tilemap",
		"path": "res://tests/functional/test_character_tilemap.tscn",
	},
	{
		"id": "Functional Tests/Character - Pixels",
		"path": "res://tests/functional/test_character_pixels.tscn",
	},
	{
		"id": "Functional Tests/One Way Collision",
		"path": "res://tests/functional/test_one_way_collision.tscn",
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
		"id": "Performance Tests/Contact Islands",
		"path": "res://tests/performance/test_perf_contact_islands.tscn",
	},
]


func _ready() -> void:
	var test_menu: OptionMenu = $TestsMenu
	for test: Variant in _tests:
		test_menu.add_test(test.id, test.path)
