extends KinematicBody2D

# Angle in degrees towards either side that the player can consider "floor".
const FLOOR_ANGLE_TOLERANCE = 40
const WALK_FORCE = 600
const WALK_MIN_SPEED = 10
const WALK_MAX_SPEED = 200
const STOP_FORCE = 1300
const JUMP_SPEED = 200
const JUMP_MAX_AIRBORNE_TIME = 0.2

const SLIDE_STOP_VELOCITY = 1.0 # Pixels/second
const SLIDE_STOP_MIN_TRAVEL = 1.0 # Pixels

var velocity = Vector2()
var on_air_time = 100
var jumping = false
var prev_jump_pressed = false

onready var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")

func _physics_process(delta):
	var force = Vector2(0, gravity)
	var walk = Input.get_action_strength("move_right") - Input.get_action_strength("move_left")
	var jump = Input.is_action_pressed("jump")

	if (velocity.x <= WALK_MIN_SPEED and velocity.x > -WALK_MAX_SPEED) or (velocity.x >= -WALK_MIN_SPEED and velocity.x < WALK_MAX_SPEED):
		force.x += WALK_FORCE * walk
	
	if abs(walk) < 0.5:
		var vsign = sign(velocity.x)
		var vlen = abs(velocity.x)
		vlen -= STOP_FORCE * delta
		if vlen < 0:
			vlen = 0
		velocity.x = vlen * vsign

	# Integrate forces to velocity.
	velocity += force * delta
	# Integrate velocity into motion and move.
	velocity = move_and_slide(velocity, Vector2.UP)

	if is_on_floor():
		on_air_time = 0

	if jumping and velocity.y > 0:
		# If falling, no longer jumping.
		jumping = false

	if on_air_time < JUMP_MAX_AIRBORNE_TIME and jump and not prev_jump_pressed and not jumping:
		# Jump must also be allowed to happen if the character left the floor a little bit ago.
		# Makes controls more snappy.
		velocity.y = -JUMP_SPEED
		jumping = true

	on_air_time += delta
	prev_jump_pressed = jump
