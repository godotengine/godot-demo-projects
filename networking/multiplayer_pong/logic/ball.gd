extends Area2D

const DEFAULT_SPEED = 100.0

var direction := Vector2.LEFT
var stopped := false
var _speed := DEFAULT_SPEED

@onready var _screen_size := get_viewport_rect().size

func _process(delta: float) -> void:
	_speed += delta
	# Ball will move normally for both players,
	# even if it's sightly out of sync between them,
	# so each player sees the motion as smooth and not jerky.
	if not stopped:
		translate(_speed * delta * direction)

	# Check screen bounds to make ball bounce.
	var ball_pos := position
	if (ball_pos.y < 0 and direction.y < 0) or (ball_pos.y > _screen_size.y and direction.y > 0):
		direction.y = -direction.y

	if is_multiplayer_authority():
		# Only the master will decide when the ball is out in
		# the left side (its own side). This makes the game
		# playable even if latency is high and ball is going
		# fast. Otherwise, the ball might be out in the other
		# player's screen but not this one.
		if ball_pos.x < 0:
			get_parent().update_score.rpc(false)
			_reset_ball.rpc(false)
	else:
		# Only the puppet will decide when the ball is out in
		# the right side, which is its own side. This makes
		# the game playable even if latency is high and ball
		# is going fast. Otherwise, the ball might be out in the
		# other player's screen but not this one.
		if ball_pos.x > _screen_size.x:
			get_parent().update_score.rpc(true)
			_reset_ball.rpc(true)


@rpc("any_peer", "call_local")
func bounce(left: bool, random: float) -> void:
	# Using sync because both players can make it bounce.
	if left:
		direction.x = abs(direction.x)
	else:
		direction.x = -abs(direction.x)

	_speed *= 1.1
	direction.y = random * 2.0 - 1
	direction = direction.normalized()


@rpc("any_peer", "call_local")
func stop() -> void:
	stopped = true


@rpc("any_peer", "call_local")
func _reset_ball(for_left: float) -> void:
	position = _screen_size / 2
	if for_left:
		direction = Vector2.LEFT
	else:
		direction = Vector2.RIGHT
	_speed = DEFAULT_SPEED
