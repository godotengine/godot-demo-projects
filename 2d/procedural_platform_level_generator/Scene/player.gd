extends CharacterBody2D

@export var rotationSpeed = 16.0   # Speed of rotation

enum State{
	IDLE,
	MOVE
}

var screenWidth
var screenHeight
var startPosition
var targetPosition
var moveDistance
var player_state
var offset = Vector2(0, 10.0)

func _ready():
	velocity.x = 250.0
	player_state = State.IDLE
	screenWidth = get_viewport_rect().size.x # It will change according to the screen size
	screenHeight = get_viewport_rect().size.y
	moveDistance = screenHeight/2
	startPosition = Vector2(screenWidth/4, (screenHeight/4)*3) # Calculated from screenDimenstions
	targetPosition = Vector2(screenWidth/4, screenHeight/4) # Calculated from screenDimenstions

func _input(event):
	if event.is_action_pressed("ui_accept", false) and player_state == State.IDLE:
		toggle_movement()
		player_state = State.MOVE

func toggle_movement():
	offset.y*=(-1)
	var temp = startPosition
	startPosition = targetPosition
	targetPosition = temp

func _physics_process(delta):
	if velocity.x < 450.00:
		velocity.x += delta
	print(velocity)
	if (player_state == State.IDLE):
		rotation += rotationSpeed * delta
		moveDistance=screenHeight/2

	if (player_state == State.MOVE):
		position-=offset
		moveDistance-=abs(offset.y)*1.15

	if((moveDistance)<=0):
		player_state = State.IDLE

	move_and_slide()

func _game_over():
	queue_free()
