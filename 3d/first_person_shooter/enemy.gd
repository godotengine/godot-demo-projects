class_name Enemy
extends CharacterBody3D

## Number of health points the enemy has.
@export var health := 100

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")

# Reference to the player (determined on initialization).
var player: Player = null

func _ready():
	player = get_tree().get_first_node_in_group("player")
	$AnimationPlayer.play("walk")


func _physics_process(delta):
	# Add the gravity.
	if not is_on_floor():
		velocity.y -= gravity * delta

	var direction := global_position.direction_to(player.global_position)
	velocity.x = direction.x * 4
	velocity.z = direction.z * 4
	move_and_slide()

	# TODO: Enemy AI

	if health <= 0:
		queue_free()
