class_name Player
extends CharacterBody2D

# Keep this in sync with the AnimationTree's state names and numbers.
enum States {
	IDLE = 0,
	WALK = 1,
	RUN = 2,
	FLY = 3,
	FALL = 4,
}

const WALK_SPEED = 200.0
const ACCELERATION_SPEED = WALK_SPEED * 6.0
const JUMP_VELOCITY = -400.0
## Maximum speed at which the player can fall.
const TERMINAL_VELOCITY = 400

var falling_slow = false
var falling_fast = false
var no_move_horizontal_time = 0.0

@onready var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")
@onready var sprite = $Sprite2D
@onready var sprite_scale = sprite.scale.x


func _ready():
	$AnimationTree.active = true


func _physics_process(delta: float) -> void:
	var is_jumping = false
	if Input.is_action_just_pressed("jump"):
		is_jumping = try_jump()
	elif Input.is_action_just_released("jump") and velocity.y < 0.0:
		# The player let go of jump early, reduce vertical momentum.
		velocity.y *= 0.6
	# Fall.
	velocity.y = minf(TERMINAL_VELOCITY, velocity.y + gravity * delta)

	var direction := Input.get_axis("move_left", "move_right") * WALK_SPEED
	velocity.x = move_toward(velocity.x, direction, ACCELERATION_SPEED * delta)

	if no_move_horizontal_time > 0.0:
		# After doing a hard fall, don't move for a short time.
		velocity.x = 0.0
		no_move_horizontal_time -= delta

	if not is_zero_approx(velocity.x):
		if velocity.x > 0.0:
			sprite.scale.x = 1.0 * sprite_scale
		else:
			sprite.scale.x = -1.0 * sprite_scale

	move_and_slide()

	# Calculate falling speed for animation purposes.
	if velocity.y >= TERMINAL_VELOCITY:
		falling_fast = true
		falling_slow = false
	elif velocity.y > 300:
		falling_slow = true
	# Check if on floor and do mostly animation stuff based on it.
	if is_on_floor():
		if falling_fast:
			$AnimationTree["parameters/land_hard/active"] = true
			no_move_horizontal_time = 0.4
			falling_fast = false
		elif falling_slow:
			$AnimationTree["parameters/land/active"] = true
			falling_slow = false

		if Input.is_action_just_pressed(&"jump"):
			$AnimationTree["parameters/jump/active"] = true

		if abs(velocity.x) > 50:
			$AnimationTree["parameters/state/current"] = States.RUN
			$AnimationTree["parameters/run_timescale/scale"] = abs(velocity.x) / 60
		elif velocity.x:
			$AnimationTree["parameters/state/current"] = States.WALK
			$AnimationTree["parameters/walk_timescale/scale"] = abs(velocity.x) / 12
		else:
			$AnimationTree["parameters/state/current"] = States.IDLE
	else:
		if velocity.y > 0:
			$AnimationTree["parameters/state/current"] = States.FALL
		else:
			$AnimationTree["parameters/state/current"] = States.FLY


func try_jump() -> bool:
	if is_on_floor():
		velocity.y = JUMP_VELOCITY
		return true
	return false
