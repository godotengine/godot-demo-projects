extends Node2D

func _process(_delta: float) -> void:
	# Keep redrawing on every frame.
	queue_redraw()


func _draw() -> void:
	# Get the touch helper singleton.
	var touch_helper: Node = $"/root/TouchHelper"
	# Draw every pointer as a circle.
	for ptr_index: int in touch_helper.state.keys():
		var pos: Vector2 = touch_helper.state[ptr_index]
		var color := _get_color_for_ptr_index(ptr_index)
		color.a = 0.75
		draw_circle(pos, 40.0, color)


## Returns a unique-looking color for the specified index.
func _get_color_for_ptr_index(index: int) -> Color:
	var x := (index % 7) + 1
	return Color(float(bool(x & 1)), float(bool(x & 2)), float(bool(x & 4)))
