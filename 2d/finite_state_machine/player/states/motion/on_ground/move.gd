extends "on_ground.gd"

export(float) var max_walk_speed = 450
export(float) var max_run_speed = 700

func enter():
	speed = 0.0
	velocity = Vector2()

	var input_direction = get_input_direction()
	update_look_direction(input_direction)
	owner.get_node("AnimationPlayer").play("walk")


func handle_input(event):
	return .handle_input(event)


func update(_delta):
	var input_direction = get_input_direction()
	if not input_direction:
		emit_signal("finished", "idle")
	update_look_direction(input_direction)

	if Input.is_action_pressed("run"):
		speed = max_run_speed
	else:
		speed = max_walk_speed

	var collision_info = move(speed, input_direction)
	if not collision_info:
		return
	if speed == max_run_speed and collision_info.collider.is_in_group("environment"):
		return null


func move(speed, direction):
	velocity = direction.normalized() * speed
	owner.move_and_slide(velocity, Vector2(), 5, 2)
	if owner.get_slide_count() == 0:
		return
	return owner.get_slide_collision(0)
