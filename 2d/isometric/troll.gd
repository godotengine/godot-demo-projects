extends CharacterBody2D

const MOTION_SPEED = 160 # Pixels/second.

func _physics_process(_delta):
	var motion = Vector2()
	motion.x = Input.get_axis(&"move_left", &"move_right")
	motion.y = Input.get_axis(&"move_up", &"move_down")
	motion.y /= 2
	motion = motion.normalized() * MOTION_SPEED
	#warning-ignore:return_value_discarded
	move_and_slide(motion)
