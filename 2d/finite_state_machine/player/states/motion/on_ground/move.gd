extends "on_ground.gd"

@export var max_walk_speed: float = 450
@export var max_run_speed: float = 700

func enter():
	speed = 0.0
	velocity = Vector2()

	var input_direction = get_input_direction()
	update_look_direction(input_direction)
	owner.get_node(^"AnimationPlayer").play("walk")


func handle_input(event):
	return super.handle_input(event)


func update(_delta):
	var input_direction = get_input_direction()
	if input_direction.is_zero_approx():
		finished.emit("idle")
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
	owner.velocity = direction.normalized() * speed
	owner.move_and_slide()
	if owner.get_slide_collision_count() == 0:
		return
	return owner.get_slide_collision(0)
