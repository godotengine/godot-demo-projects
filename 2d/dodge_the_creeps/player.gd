## Player-controlled character with movement and collision detection
## See README: Node Inheritance & Types, Signals
## Area2D provides collision detection, signals enable inter-node communication
extends Area2D

signal hit  ## Emitted when player collides with enemy

@export var speed = 400  ## Movement speed in pixels/sec
var screen_size

func _ready():
	screen_size = get_viewport_rect().size
	hide()

func _process(delta):
	## Handle input and movement
	var velocity = Vector2.ZERO
	if Input.is_action_pressed(&"move_right"):
		velocity.x += 1
	if Input.is_action_pressed(&"move_left"):
		velocity.x -= 1
	if Input.is_action_pressed(&"move_down"):
		velocity.y += 1
	if Input.is_action_pressed(&"move_up"):
		velocity.y -= 1

	if velocity.length() > 0:
		## See README: Player Movement - Normalization
		## Prevents diagonal movement from being faster than horizontal/vertical
		velocity = velocity.normalized() * speed
		$AnimatedSprite2D.play()
	else:
		$AnimatedSprite2D.stop()

	## See README: Player Movement - Delta Time
	## Ensures constant movement speed regardless of framerate
	position += velocity * delta
	## See README: Player Movement - Screen clamping
	## Keeps player within screen boundaries
	position = position.clamp(Vector2.ZERO, screen_size)

	## Update animation based on movement direction
	if velocity.x != 0:
		$AnimatedSprite2D.animation = &"right"
		$AnimatedSprite2D.flip_v = false
		$Trail.rotation = 0
		$AnimatedSprite2D.flip_h = velocity.x < 0
	elif velocity.y != 0:
		$AnimatedSprite2D.animation = &"up"
		rotation = PI if velocity.y > 0 else 0.0

func start(pos):
	## Initialize player at starting position
	position = pos
	rotation = 0
	show()
	$CollisionShape2D.disabled = false

func _on_body_entered(_body):
	## Handle collision with enemy
	hide()
	hit.emit()
	## See README: set_deferred() - Physics engine safety
	## Defers changes until physics engine is ready to avoid errors
	$CollisionShape2D.set_deferred(&"disabled", true)
