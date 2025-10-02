extends "../motion.gd"

var speed := 0.0
var velocity := Vector2()

func handle_input(input_event: InputEvent) -> void:
	if input_event.is_action_pressed("jump"):
		finished.emit(PLAYER_STATE.jump)
	return super.handle_input(input_event)
