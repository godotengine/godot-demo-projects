extends "on_ground.gd"

func enter() -> void:
	owner.get_node(^"AnimationPlayer").play(PLAYER_STATE.idle)


func handle_input(input_event: InputEvent) -> void:
	return super.handle_input(input_event)


func update(_delta: float) -> void:
	var input_direction: Vector2 = get_input_direction()
	if input_direction:
		finished.emit(PLAYER_STATE.move)
