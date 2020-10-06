extends Area2D

signal hit

# These only need to be accessed in this script, so we can make them private.
# Private variables in GDScript have their name starting with an underscore.
export var _speed = 400 # How fast the player will move (pixels/sec).
var _screen_size # Size of the game window.

func _ready():
	_screen_size = get_viewport_rect().size
	hide()


func _process(delta):
	var velocity = Vector2() # The player's movement vector.
	velocity.x = Input.get_action_strength("move_right") - Input.get_action_strength("move_left")
	velocity.y = Input.get_action_strength("move_down") - Input.get_action_strength("move_up")

	if velocity.length() > 0:
		velocity = velocity.normalized() * _speed
		$AnimatedSprite.play()
	else:
		$AnimatedSprite.stop()

	position += velocity * delta
	position.x = clamp(position.x, 0, _screen_size.x)
	position.y = clamp(position.y, 0, _screen_size.y)

	if velocity.x != 0:
		$AnimatedSprite.animation = "right"
		$AnimatedSprite.flip_v = false
		$AnimatedSprite.flip_h = velocity.x < 0
	elif velocity.y != 0:
		$AnimatedSprite.animation = "up"
		$AnimatedSprite.flip_v = velocity.y > 0


func start(pos):
	position = pos
	show()
	# Must be deferred as we can't change physics properties on a physics callback.
	$CollisionShape2D.set_deferred("disabled", false)


func _on_Player_body_entered(_body):
	hide() # Player disappears after being hit.
	emit_signal("hit")
	# Must be deferred as we can't change physics properties on a physics callback.
	$CollisionShape2D.set_deferred("disabled", true)
