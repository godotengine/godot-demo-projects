extends KinematicBody2D

# The player's movement speed.
const MOVE_SPEED = 240

var health = 100 setget set_health
var motion = Vector2()

onready var progress_bar = $Sprite/ProgressBar


func _process(delta):
	# Player movement (controller-friendly).
	var velocity = Vector2.ZERO
	velocity.x = Input.get_action_strength("move_right") - Input.get_action_strength("move_left")
	velocity.y = Input.get_action_strength("move_down") - Input.get_action_strength("move_up")
	position += velocity * MOVE_SPEED * delta

	# Prevent the player from going outside the window.
	position.x = clamp(position.x, 32, 700)
	position.y = clamp(position.y, 32, 536)

func set_health(p_health):
	health = p_health
	progress_bar.value = health

	if health <= 0:
		# The player died.
		# warning-ignore:return_value_discarded
		get_tree().reload_current_scene()
