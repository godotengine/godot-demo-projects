extends "../motion.gd"

@export var base_max_horizontal_speed := 400.0

@export var air_acceleration := 1000.0
@export var air_deceleration := 2000.0
@export var air_steering_power := 50.0

@export var gravity := 1600.0

var enter_velocity := Vector2()

var max_horizontal_speed := 0.0
var horizontal_speed := 0.0
var horizontal_velocity := Vector2()

var vertical_speed := 0.0
var height := 0.0

func initialize(speed: float, velocity: Vector2) -> void:
	horizontal_speed = speed
	if speed > 0.0:
		max_horizontal_speed = speed
	else:
		max_horizontal_speed = base_max_horizontal_speed
	enter_velocity = velocity


func enter() -> void:
	var input_direction := get_input_direction()
	update_look_direction(input_direction)

	if input_direction:
		horizontal_velocity = enter_velocity
	else:
		horizontal_velocity = Vector2()
	vertical_speed = 600.0

	owner.get_node(^"AnimationPlayer").play("idle")


func update(delta: float) -> void:
	var input_direction := get_input_direction()
	update_look_direction(input_direction)

	move_horizontally(delta, input_direction)
	animate_jump_height(delta)
	if height <= 0.0:
		finished.emit("previous")


func move_horizontally(delta: float, direction: Vector2) -> void:
	if direction:
		horizontal_speed += air_acceleration * delta
	else:
		horizontal_speed -= air_deceleration * delta
	horizontal_speed = clamp(horizontal_speed, 0, max_horizontal_speed)

	var target_velocity := horizontal_speed * direction.normalized()
	var steering_velocity := (target_velocity - horizontal_velocity).normalized() * air_steering_power
	horizontal_velocity += steering_velocity

	owner.velocity = horizontal_velocity
	owner.move_and_slide()


func animate_jump_height(delta: float) -> void:
	vertical_speed -= gravity * delta
	height += vertical_speed * delta
	height = max(0.0, height)

	owner.get_node(^"BodyPivot").position.y = -height
