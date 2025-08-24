extends CharacterBody2D

const MOTION_SPEED = 30
const FRICTION_FACTOR = 0.89
const TAN30DEG = tan(deg_to_rad(30))

func _physics_process(_delta: float) -> void:
	var motion := Vector2()
	motion.x = Input.get_axis(&"move_left", &"move_right")
	motion.y = Input.get_axis(&"move_up", &"move_down")
	# Make diagonal movement fit for hexagonal tiles.
	motion.y *= TAN30DEG
	velocity += motion.normalized() * MOTION_SPEED
	# Apply friction.
	velocity *= FRICTION_FACTOR
	move_and_slide()
