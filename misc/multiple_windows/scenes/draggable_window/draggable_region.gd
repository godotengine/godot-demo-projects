extends Area2D

func _input_event(_viewport: Viewport, event: InputEvent, _shape_index: int) -> void:
	if event is InputEventMouseButton:
		if event.pressed:
			get_window().start_drag()
