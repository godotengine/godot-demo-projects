extends Area2D

const DEFAULT_SPEED = 80

var direction = Vector2(1, 0)
var ball_speed = DEFAULT_SPEED
var stopped = false


onready var screen_size = get_viewport_rect().size


sync func _reset_ball(for_left):
	position = screen_size /2
	if for_left:
		direction = Vector2(-1, 0)
	else:
		direction = Vector2(1, 0)

	ball_speed = DEFAULT_SPEED


sync func stop():
	stopped = true


func _process(delta):	
	# ball will move normally for both players
	# even if it's sightly out of sync between them
	# so each player sees the motion as smooth and not jerky
	
	if not stopped:
		translate( direction * ball_speed * delta ) 
	
	# check screen bounds to make ball bounce
	
	var ball_pos = position
	if (ball_pos.y < 0 and direction.y < 0) or (ball_pos.y > screen_size.y and direction.y > 0):
		direction.y = -direction.y
		
	if is_network_master():
		# only master will decide when the ball is out in the left side (it's own side)
		# this makes the game playable even if latency is high and ball is going fast
		# otherwise ball might be out in the other player's screen but not this one
		
		if ball_pos.x < 0:
			get_parent().rpc("update_score", false)
			rpc("_reset_ball", false)
	else:
		# only the puppet will decide when the ball is out in the right side (it's own side)
		# this makes the game playable even if latency is high and ball is going fast
		# otherwise ball might be out in the other player's screen but not this one
		
		if ball_pos.x > screen_size.x:
			get_parent().rpc("update_score", true)
			rpc("_reset_ball", true)
		
	
sync func bounce(left, random):
	#using sync because both players can make it bounce
	if left:		
		direction.x = abs(direction.x)
	else:
		direction.x = -abs(direction.x)
		
	ball_speed *= 1.1
	direction.y = random * 2.0 - 1
	direction = direction.normalized()
