extends Node2D

const PAD_SPEED = 150
const INITIAL_BALL_SPEED = 80

var ball_speed = INITIAL_BALL_SPEED
var screen_size = Vector2(640, 400)

# Default ball direction.
var direction = Vector2.LEFT
var pad_size = Vector2(8, 32)

onready var ball = $Ball
onready var left_paddle = $LeftPaddle
onready var right_paddle = $RightPaddle

func _ready():
	screen_size = get_viewport_rect().size # Get actual size.
	pad_size = left_paddle.get_texture().get_size()


func _process(delta):
	# Get ball position and pad rectangles.
	var ball_pos = ball.get_position()
	var left_rect = Rect2(left_paddle.get_position() - pad_size * 0.5, pad_size)
	var right_rect = Rect2(right_paddle.get_position() - pad_size * 0.5, pad_size)

	# Integrate new ball postion.
	ball_pos += direction * ball_speed * delta

	# Flip when touching roof or floor.
	if (ball_pos.y < 0 and direction.y < 0) or (ball_pos.y > screen_size.y and direction.y > 0):
		direction.y = -direction.y

	# Flip, change direction and increase speed when touching pads.
	if (left_rect.has_point(ball_pos) and direction.x < 0) or (right_rect.has_point(ball_pos) and direction.x > 0):
		direction.x = -direction.x
		ball_speed *= 1.1
		direction.y = randf() * 2.0 - 1
		direction = direction.normalized()

	# Check gameover.
	if ball_pos.x < 0 or ball_pos.x > screen_size.x:
		ball_pos = screen_size * 0.5
		ball_speed = INITIAL_BALL_SPEED
		direction = Vector2(-1, 0)

	ball.set_position(ball_pos)

	# Move left pad.
	var left_pos = left_paddle.get_position()

	if left_pos.y > 0 and Input.is_action_pressed("left_move_up"):
		left_pos.y += -PAD_SPEED * delta
	if left_pos.y < screen_size.y and Input.is_action_pressed("left_move_down"):
		left_pos.y += PAD_SPEED * delta

	left_paddle.set_position(left_pos)

	# Move right pad.
	var right_pos = right_paddle.get_position()
	if right_pos.y > 0 and Input.is_action_pressed("right_move_up"):
		right_pos.y += -PAD_SPEED * delta
	if right_pos.y < screen_size.y and Input.is_action_pressed("right_move_down"):
		right_pos.y += PAD_SPEED * delta

	right_paddle.set_position(right_pos)
