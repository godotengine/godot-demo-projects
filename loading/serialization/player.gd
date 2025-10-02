class_name Player
extends CharacterBody2D

## Movement speed in pixels per second.
const MOVEMENT_SPEED = 240.0

var health := 100.0:
	get:
		return health
	set(value):
		health = value
		progress_bar.value = value
		if health <= 0.0:
			# The player died.
			get_tree().reload_current_scene()
var motion := Vector2()

@onready var progress_bar := $ProgressBar as ProgressBar
@onready var sprite := $Sprite2D as Sprite2D

func _process(_delta: float) -> void:
	velocity = Input.get_vector(&"move_left", &"move_right", &"move_up", &"move_down")
	if velocity.length_squared() > 1.0:
		velocity = velocity.normalized()
	velocity *= MOVEMENT_SPEED
	move_and_slide()


func _input(event: InputEvent) -> void:
	if event.is_action_pressed(&"move_left"):
		sprite.rotation = PI / 2
	elif event.is_action_pressed(&"move_right"):
		sprite.rotation = -PI / 2
	elif event.is_action_pressed(&"move_up"):
		sprite.rotation = PI
	elif event.is_action_pressed(&"move_down"):
		sprite.rotation = 0.0
