extends "on_ground.gd"

func enter() -> void:
	owner.get_node(^"AnimationPlayer").play("idle")


func handle_input(event: InputEvent) -> void:
	return super.handle_input(event)


func update(_delta: float) -> void:
	var input_direction: Vector2 = get_input_direction()
	if input_direction:
		finished.emit("move")
