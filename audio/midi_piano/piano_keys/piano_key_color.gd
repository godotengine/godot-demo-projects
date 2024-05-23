extends ColorRect

@onready var parent: PianoKey = get_parent()

# Yes, this script exists just for this one method.
func _gui_input(input_event: InputEvent) -> void:
	if input_event is InputEventMouseButton and input_event.pressed:
		parent.activate()
