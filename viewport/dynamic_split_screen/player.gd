extends CharacterBody3D

# Moves the player

@export var player_id: int, 1, 2 = 1
@export var walk_speed: float = 20.0


func _physics_process(_delta):
	var velocity = Vector3.ZERO
	velocity.z = -Input.get_action_strength("move_up_player" + str(player_id))
	velocity.z += Input.get_action_strength("move_down_player" + str(player_id))
	velocity.x = -Input.get_action_strength("move_left_player" + str(player_id))
	velocity.x +=  Input.get_action_strength("move_right_player" + str(player_id))

	move_and_slide(velocity.normalized() * walk_speed)
