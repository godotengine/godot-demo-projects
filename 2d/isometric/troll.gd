extends CharacterBody2D

const MOTION_SPEED = 30 # Pixels/second.
const FRICTION_FACTOR = 0.89

func _physics_process(_delta):
	var motion = Vector2()
	motion.x = Input.get_axis(&"move_left", &"move_right")
	motion.y = Input.get_axis(&"move_up", &"move_down")
	# Make diagonal movement fit isometric tiles.
	motion.y /= 2
	velocity += motion.normalized() * MOTION_SPEED
	# Apply friction.
	velocity *= FRICTION_FACTOR
	move_and_slide()
