extends Walker

func _process(_delta: float) -> void:
	var input_direction := get_input_direction()
	# We only move in integer increments.
	input_direction = input_direction.round()

	if input_direction.is_zero_approx():
		return

	update_look_direction(input_direction)

	var target_position: Vector2 = grid.request_move(self, input_direction)
	if target_position:
		move_to(target_position)
	elif active:
		bump()


func get_input_direction() -> Vector2:
	return Input.get_vector(&"move_left", &"move_right", &"move_up", &"move_down")
