extends Area2D

var window_delta: Vector2i

var held_down: bool = false

func _input_event(_viewport, event, _shape_idx):
	if event is InputEventMouseButton:
		held_down = event.pressed
		if event.pressed:
			window_delta = get_window().position - DisplayServer.mouse_get_position()


func _process(_delta):
	if held_down:
		get_window().position = DisplayServer.mouse_get_position() + window_delta
		var mouse_state = DisplayServer.mouse_get_button_state()
		if mouse_state & MOUSE_BUTTON_MASK_LEFT == 0:
			held_down = false
