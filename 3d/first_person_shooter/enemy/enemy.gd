class_name Enemy
extends CharacterBody3D

## Number of health points the enemy has.
@export var health := 100

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")

# Reference to the player (determined on initialization).
var player: Player = null

# If `true`, the enemy can currently see the player (and should act upon it).
var can_see_player := false

# Target position for the next bullet to fire (in global coordinates).
@onready var bullet_target_position := Vector3.ZERO

# Used for resetting the fixed wait time after the initial jitter.
@onready var line_of_sight_timer_initial_wait_time: float = $LineOfSightTimer.wait_time

## Maximum distance at which enemies will attempt to fire their weapon.
const MAX_FIRING_DISTANCE = 25.0

func _ready():
	player = get_tree().get_first_node_in_group("player")

	# Jitter line of sight timer to avoid stuttering due to performing lots of RayCasts in the same frame.
	$LineOfSightTimer.wait_time *= randf()


func _physics_process(delta):
	# Add the gravity.
	if not is_on_floor():
		velocity.y -= gravity * delta

	if can_see_player:
		var distance := global_position.distance_to(player.global_position)
		# Look towards the player (the mesh's rotation affects the currently shown 2.5D sprite).
		$Sprite.global_transform = global_transform.looking_at(player.global_position)

		# Don't move towards the player if very close already, or if currently playing a firing or pain animation.
		if distance > 2.0 and $AnimationPlayer.current_animation == &"walk":
			var direction := global_position.direction_to(player.global_position)
			velocity.x = direction.x * 4
			velocity.z = direction.z * 4
			move_and_slide()

		if is_zero_approx($ShootTimer.time_left) and distance < MAX_FIRING_DISTANCE:
			# Set the target position for the bullet before the animation is played.
			# This allows the final shot to be visibly delayed, allowing players to dodge bullets
			# by strafing.
			bullet_target_position = player.global_position

			# Shot frequency is proportional to distance.
			# The closer the enemy is to the player, the more frequently they will fire.
			$ShootTimer.start(remap(distance, 0.0, MAX_FIRING_DISTANCE, 0.6, 2.0))
			# Note: For enemy animations to play independently of other enemies,
			# the mesh's material must be set as Local To Scene in the inspector.
			# The `fire` animation handles the actual bullet firing with a Call Method track.
			$AnimationPlayer.play("fire")
			$AnimationPlayer.queue("walk")

	if health <= 0:
		queue_free()


func _on_line_of_sight_timer_timeout() -> void:
	# Set the fixed wait time back, now that the first iteration with jittered wait time has passed.
	$LineOfSightTimer.wait_time = line_of_sight_timer_initial_wait_time

	# Convert player position to be relative to the enemy's position (as `target_position` is in local space).
	# This line of sight is used to check whether the enemy should chase and shoot the player.
	$LineOfSight.enabled = true
	$LineOfSight.target_position = player.global_position - position
	# Allow performing queries immediately after enabling the RayCast.
	# Otherwise, we would have to wait one physics frame.
	$LineOfSight.force_raycast_update()
	can_see_player = player.health >= 1 and not $LineOfSight.is_colliding()

	# Disable RayCast once it's not needed anymore (until the next timer timeout) to improve performance.
	$LineOfSight.enabled = false


## Fires a bullet towards the position stored in `bullet_target_position` (method called by AnimationPlayer).
func fire_bullet() -> void:
	var bullet := preload("res://bullet.tscn").instantiate()
	# Bullets are not child of the player to prevent moving along the player.
	get_parent().add_child(bullet)
	bullet.global_transform = global_transform.looking_at(bullet_target_position)
	# Apply random spread (twice as much spread horizontally than vertically).
	bullet.rotation.y += -0.1 + randf() * 0.2
	bullet.rotation.x += -0.05 + randf() * 0.1


## Called when receiving damage.
func damage(p_damage: int) -> void:
	health -= p_damage
	$AnimationPlayer.play("pain")
	$AnimationPlayer.queue("walk")
