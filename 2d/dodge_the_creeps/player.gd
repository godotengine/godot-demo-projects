extends Area2D

## Initialize a signal to notify the main scene when the player is hit.
## You can see now the signal in the editor when you select the Player node.
signal hit

@export var speed = 400 # How fast the player will move (pixels/sec).
var screen_size # Size of the game window.


func _ready():
	screen_size = get_viewport_rect().size
	hide()


func _process(delta):

	## Handle player movement.
	## Set the velocity vector to zero when no keys are pressed.
	var velocity = Vector2.ZERO # The player's movement vector.
	## Check for input and adjust the velocity vector accordingly.
	if Input.is_action_pressed(&"move_right"):
		velocity.x += 1
	if Input.is_action_pressed(&"move_left"):
		velocity.x -= 1
	## Quick note: The y-axis in Godot points down
	## so moving down increases y and moving up decreases y.
	if Input.is_action_pressed(&"move_down"):
		velocity.y += 1
	if Input.is_action_pressed(&"move_up"):
		velocity.y -= 1

	## If the velocity vector's length is greater than zero, the player is moving.
	if velocity.length() > 0:
		## Normalize the velocity so that diagonal movement isn't faster.
		## Then scale it by the speed value to get the final velocity.
		velocity = velocity.normalized() * speed
		## Play the animation if the player is moving.
		$AnimatedSprite2D.play()
	else:
		#Stop the animation if the player is not moving.
		$AnimatedSprite2D.stop()

	## Move the player with the velocity vector and Delta time.
	## Delta time is the time elapsed since the previous frame.
	## Multiplying the velocity by Delta time ensures 
	## that the player moves at the same speed regardless of the frame rate.
	position += velocity * delta

	## Ensure the player does not move off the screen.
	position = position.clamp(Vector2.ZERO, screen_size)

	## Handle the player's animation and rotation based on movement direction.
	if velocity.x != 0:
		## If moving horizontally, use the "right" animation.
		$AnimatedSprite2D.animation = &"right"
		## Reset rotation of Sprite and trail when moving horizontally.
		$AnimatedSprite2D.flip_v = false
		$Trail.rotation = 0
		## flip the sprite when moving left.
		$AnimatedSprite2D.flip_h = velocity.x < 0
	elif velocity.y != 0:
		## If moving vertically, use the "up" animation.
		$AnimatedSprite2D.animation = &"up"
		## Turn the sprite upside down when moving down.
		rotation = PI if velocity.y > 0 else 0.0

## Called by the main scene to start the player.
func start(pos):
	## Initialize the player's position.
	position = pos
	## Reset the player's rotation.
	rotation = 0
	## Show the player and enable its collision shape.
	show()
	## Enable the collision shape if we had disabled it when hit.
	$CollisionShape2D.disabled = false


func _on_body_entered(_body):
	hide() # Player disappears after being hit.
	## Emit the hit signal so the main scene can handle it.
	hit.emit()
	# Must be deferred as we can't change physics properties on a physics callback.
	$CollisionShape2D.set_deferred(&"disabled", true)
