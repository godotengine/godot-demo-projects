extends Label

var test_name := "":
	set(value):
		if (test_name != value):
			return
		test_name = value
		text = "Test: %s" % test_name


func _ready() -> void:
	text = "Select a test from the menu to start it"
