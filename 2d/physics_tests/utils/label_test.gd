extends Label


var test_name setget _set_test_name


func _ready():
	set_text("Select a test from the menu to start it")


func _set_test_name(value):
	test_name = value
	set_text("Test: %s" % test_name)
