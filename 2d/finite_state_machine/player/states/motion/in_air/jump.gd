extends "../motion.gd"

export(float) var BASE_MAX_HORIZONTAL_SPEED = 400.0

export(float) var AIR_ACCELERATION = 1000.0
export(float) var AIR_DECCELERATION = 2000.0
export(float) var AIR_STEERING_POWER = 50.0

export(float) var JUMP_HEIGHT = 120.0
export(float) var JUMP_DURATION = 0.8

export(float) var GRAVITY = 1600.0


var enter_velocity = Vector2()

var max_horizontal_speed = 0.0
var horizontal_speed = 0.0
var horizontal_velocity = Vector2()

var vertical_speed = 0.0
var height = 0.0


func initialize(speed, velocity):
	horizontal_speed = speed
	max_horizontal_speed = speed if speed > 0.0 else BASE_MAX_HORIZONTAL_SPEED
	enter_velocity = velocity


func enter(host):
	var input_direction = get_input_direction()
	update_look_direction(host, input_direction)

	horizontal_velocity = enter_velocity if input_direction else Vector2()
	vertical_speed = 600.0

	host.get_node("AnimationPlayer").play("idle")


func update(host, delta):
	var input_direction = get_input_direction()
	update_look_direction(host, input_direction)

	move_horizontally(host, delta, input_direction)
	animate_jump_height(host, delta)
	if height <= 0.0:
		emit_signal("finished", "previous")


func move_horizontally(host, delta, direction):
	if direction:
		horizontal_speed += AIR_ACCELERATION * delta
	else:
		horizontal_speed -= AIR_DECCELERATION * delta
	horizontal_speed = clamp(horizontal_speed, 0, max_horizontal_speed)

	var target_velocity = horizontal_speed * direction.normalized()
	var steering_velocity = (target_velocity - horizontal_velocity).normalized() * AIR_STEERING_POWER
	horizontal_velocity += steering_velocity

	host.move_and_slide(horizontal_velocity)


func animate_jump_height(host, delta):
	vertical_speed -= GRAVITY * delta
	height += vertical_speed * delta
	height = max(0.0, height)

	host.get_node("BodyPivot").position.y = -height
