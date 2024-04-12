extends "on_ground.gd"

func enter():
	owner.get_node(^"AnimationPlayer").play("idle")


func handle_input(event):
	return super.handle_input(event)


func update(_delta):
	var input_direction = get_input_direction()
	if input_direction:
		finished.emit("move")
