extends Area2D


func _input_event(_viewport: Viewport, input_event: InputEvent, _shape_index: int) -> void:
	if input_event is InputEventMouseButton:
		if input_event.pressed:
			get_window().start_drag()
