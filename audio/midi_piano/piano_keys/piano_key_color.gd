extends ColorRect

onready var parent = get_parent()

# Yes, this script exists just for this one method.
func _gui_input(input_event):
	if input_event is InputEventMouseButton and input_event.pressed:
		parent.activate()
