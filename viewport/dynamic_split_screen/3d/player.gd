extends KinematicBody

# Moves the player

export(int, 1, 2) var player_id = 1
export(float) var walk_speed = 20.0


func _physics_process(_delta):
	var velocity = Vector3.ZERO
	velocity.z = -Input.get_action_strength("move_up_player" + str(player_id))
	velocity.z += Input.get_action_strength("move_down_player" + str(player_id))
	velocity.x = -Input.get_action_strength("move_left_player" + str(player_id))
	velocity.x +=  Input.get_action_strength("move_right_player" + str(player_id))

	move_and_slide(velocity.normalized() * walk_speed)
