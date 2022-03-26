extends CharacterBody2D

# The player's movement speed.
const MOVE_SPEED = 240

var health = 100:
	set(value):
		# TODO: Manually copy the code from this method.
		set_health(value)
var motion = Vector2()

@onready var progress_bar = $Sprite2D/ProgressBar


func _process(delta):
	# Player movement (controller-friendly).
	var velocity = Vector2.ZERO
	velocity.x = Input.get_axis(&"move_left", &"move_right")
	velocity.y = Input.get_axis(&"move_up", &"move_down")
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
