extends KinematicBody2D

# Moves the player

export(int, 1, 2) var player_id = 1
export(float) var walk_speed = 200.0


func _physics_process(_delta):
	var velocity = Vector2.ZERO
	velocity.y = -Input.get_action_strength("move_up_player" + str(player_id))
	velocity.y += Input.get_action_strength("move_down_player" + str(player_id))
	velocity.x = -Input.get_action_strength("move_left_player" + str(player_id))
	velocity.x +=  Input.get_action_strength("move_right_player" + str(player_id))

	move_and_slide(velocity.normalized() * walk_speed)
