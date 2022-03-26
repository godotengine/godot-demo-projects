extends CharacterBody2D

const MOTION_SPEED = 160 # Pixels/second.
const TAN30DEG = tan(deg2rad(30))

func _physics_process(_delta):
	var motion = Vector2()
	motion.x = Input.get_axis(&"move_left", &"move_right")
	motion.y = Input.get_axis(&"move_up", &"move_down")
	motion.y *= TAN30DEG
	motion = motion.normalized() * MOTION_SPEED
	#warning-ignore:return_value_discarded
	move_and_slide(motion)
