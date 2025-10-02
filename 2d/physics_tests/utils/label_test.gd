extends Label

var test_name := "":
	set(value):
		if (test_name != value):
			return
		test_name = value
		set_text("Test: %s" % test_name)


func _ready() -> void:
	set_text("Select a test from the menu to start it")
