extends StaticBody3D

## Distance to travel upwards in units.
@export var distance := 20.0

## Speed in units per second.
@export var speed := 9.0

# The current platform's speed.
# Positive: going upwards, negative: going downwards, zero: stopped.
var velocity := 0.0

# If `true`, a player is currently on the platform.
var player_on_platform := false

@onready var initial_height := position.y

func _process(delta: float) -> void:
	position.y = clamp(position.y + velocity * delta, initial_height, initial_height + distance)

	if is_equal_approx(position.y, initial_height):
		# Reached the bottom.
		velocity = 0.0

	if is_equal_approx(position.y, initial_height + distance):
		# Reached the top.
		velocity = 0.0
		if $Timer.is_stopped():
			# Start timer that will make the platform go back down when timing out.
			$Timer.start()


func _on_move_trigger_body_entered(body: Node3D) -> void:
	if body is Player:
		player_on_platform = true
		if velocity >= 0.0:
			velocity = speed


func _on_move_trigger_body_exited(body: Node3D) -> void:
	player_on_platform = false
	if is_zero_approx(velocity) and is_zero_approx($Timer.get_time_left()):
		# If the timer already expired, start going downwards immediately.
		velocity = -speed


func _on_timer_timeout() -> void:
	# Only move downwards if the player is not currently on the platform.
	# This allows the player to stay indefinitely on a fully raised platform,
	# as long as they don't leave it.
	if not player_on_platform:
		velocity = -speed

