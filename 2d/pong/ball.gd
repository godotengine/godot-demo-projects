extends Area2D

const BALL_SPEED = 100
var direction = Vector2(-1, 0)
var speed = BALL_SPEED

onready var initial_pos = self.position

func reset():
	position = initial_pos
	speed = BALL_SPEED
	direction = Vector2(-1, 0)

func _process(delta):
	position += direction * speed * delta
	
