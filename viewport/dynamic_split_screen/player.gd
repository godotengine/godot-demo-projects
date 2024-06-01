extends CharacterBody3D

# Moves the player

@export_range(1, 2) var player_id := 1
@export var walk_speed := 2.0


func _physics_process(_delta: float) -> void:
	var move_direction := Input.get_vector(
			&"move_left_player" + str(player_id),
			&"move_right_player" + str(player_id),
			&"move_up_player" + str(player_id),
			&"move_down_player" + str(player_id),
	)
	velocity.x += move_direction.x * walk_speed
	velocity.z += move_direction.y * walk_speed

	# Apply friction.
	velocity *= 0.9

	move_and_slide()
