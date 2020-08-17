extends KinematicBody

const MAX_SPEED = 5
const JUMP_SPEED = 7
const ACCELERATION = 2
const DECELERATION = 4
const MAX_SLOPE_ANGLE = 30

onready var gravity = -ProjectSettings.get_setting("physics/3d/default_gravity")
var velocity: Vector3

func _physics_process(delta):
	if Input.is_action_just_pressed("exit"):
		get_tree().quit()
	if Input.is_action_just_pressed("reset_position"):
		translation = Vector3(-3, 4, 8)

	var dir = Vector3()
	dir.x = Input.get_action_strength("move_right") - Input.get_action_strength("move_left")
	dir.z = Input.get_action_strength("move_back") - Input.get_action_strength("move_forward")

	# Get the camera's transform basis, but remove the X rotation such
	# that the Y axis is up and Z is horizontal.
	var cam_basis = $Target/Camera.global_transform.basis
	var basis = cam_basis.rotated(cam_basis.x, -cam_basis.get_euler().x)
	dir = basis.xform(dir)

	# Limit the input to a length of 1. length_squared is faster to check.
	if dir.length_squared() > 1:
		dir /= dir.length()

	# Apply gravity.
	velocity.y += delta * gravity

	# Using only the horizontal velocity, interpolate towards the input.
	var hvel = velocity
	hvel.y = 0

	var target = dir * MAX_SPEED
	var acceleration
	if dir.dot(hvel) > 0:
		acceleration = ACCELERATION
	else:
		acceleration = DECELERATION

	hvel = hvel.linear_interpolate(target, acceleration * delta)

	# Assign hvel's values back to velocity, and then move.
	velocity.x = hvel.x
	velocity.z = hvel.z
	velocity = move_and_slide(velocity, Vector3.UP)

	# Jumping code. is_on_floor() must come after move_and_slide().
	if is_on_floor() and Input.is_action_pressed("jump"):
		velocity.y = JUMP_SPEED


func _on_tcube_body_entered(body):
	if body == self:
		get_node("WinText").show()
