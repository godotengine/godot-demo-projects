extends Node3D

@onready var sprite: AnimatedSprite3D = $AnimatedSprite3D
@export var move_speed: float = 5.0

var velocity: Vector3 = Vector3.ZERO


func _process(delta: float) -> void:
	var input_vector: Vector2 = Vector2.ZERO

	input_vector.x = Input.get_action_strength("move_right") - Input.get_action_strength("move_left")
	input_vector.y = Input.get_action_strength("move_back") - Input.get_action_strength("move_forward")

	if input_vector.length() > 0:
		input_vector = input_vector.normalized()
		# Update player's position in 3D space.
		velocity = Vector3(input_vector.x, 0, input_vector.y) * move_speed
		translate(velocity * delta)

		# Play corresponding animation.
		if abs(input_vector.x) > abs(input_vector.y):
			sprite.play("walk_right" if input_vector.x > 0 else "walk_left")
		else:
			sprite.play("walk_down" if input_vector.y > 0 else "walk_up")
	else:
		sprite.stop()
