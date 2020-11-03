extends KinematicBody2D



export(int) var speed = 400

var motion = Vector2.ZERO

onready var animation = $Animation


func _ready():
	# Sets the pause mode to stop, this node and it's childern
	# will stop processing if the Scene Tree was paused.
	set_pause_mode(1)



func _physics_process(delta):
	# Gets the input strength (a value between 0 and 1.0) for each axis.
	motion.x = Input.get_action_strength("ui_right") - Input.get_action_strength("ui_left")
	motion.y = Input.get_action_strength("ui_down") - Input.get_action_strength("ui_up")
	motion = motion.normalized()
	
	if Input.is_action_pressed("ui_up"):
		animation.play("up")
	elif Input.is_action_pressed("ui_down"):
		animation.play("down")
	elif motion.x <= 0.1:
		animation.play("idle")
	
	if Input.is_action_pressed("ui_left"):
		animation.play("left")
	elif Input.is_action_pressed("ui_right"):
		animation.play("right")
	elif motion.y <= 0.1:
		animation.play("idle")
	
	
	motion = motion * speed  # Multiplies the strength values by speed value.
	motion = move_and_slide(motion)
