extends Control


func _input(input_event: InputEvent) -> void:
	if input_event.is_action_pressed(&"toggle_control_hints"):
		visible = not visible
