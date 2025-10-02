extends "res://player/player_state.gd"
# Collection of important methods to handle direction and animation.

func handle_input(input_event: InputEvent) -> void:
	if input_event.is_action_pressed("simulate_damage"):
		finished.emit(PLAYER_STATE.stagger)


func get_input_direction() -> Vector2:
	return Vector2(
			Input.get_axis(&"move_left", &"move_right"),
			Input.get_axis(&"move_up", &"move_down")
	)


func update_look_direction(direction: Vector2) -> void:
	if direction and owner.look_direction != direction:
		owner.look_direction = direction
