extends XROrigin3D

# Settings to control the character.
@export var rotation_speed := 1.0
@export var movement_speed := 5.0
@export var movement_acceleration := 5.0

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity := float(ProjectSettings.get_setting("physics/3d/default_gravity"))

# Helper variables to keep our code readable.
@onready var character_body : CharacterBody3D = $CharacterBody3D
@onready var camera_node : XRCamera3D = $XRCamera3D
@onready var neck_position_node : Node3D = $XRCamera3D/Neck
@onready var black_out : Node3D = $XRCamera3D/BlackOut

## Called when the user has requested their view to be recentered.
func recenter() -> void:
	# The code here assumes the player has walked into an area they shouldn't be
	# and we return the player back to the character body.
	# But other strategies can be applied here as well such as returning the player
	# to a starting position or a checkpoint.

	# Calculate where our camera should be, we start with our global transform.
	var new_camera_transform: Transform3D = character_body.global_transform

	# Set to the height of our neck joint.
	new_camera_transform.origin.y = neck_position_node.global_position.y

	# Apply transform our our next position to get our desired camera transform.
	new_camera_transform = new_camera_transform * neck_position_node.transform.inverse()

	# Remove tilt from camera transform.
	var camera_transform: Transform3D = camera_node.transform
	var forward_dir: Vector3 = camera_transform.basis.z
	forward_dir.y = 0.0
	camera_transform = camera_transform.looking_at(camera_transform.origin + forward_dir.normalized(), Vector3.UP, true)

	# Update our XR location.
	global_transform = new_camera_transform * camera_transform.inverse()

	# Recenter character body.
	character_body.transform = Transform3D()

# `_get_movement_input()` returns our move input by querying the move action on each controller.
func _get_movement_input() -> Vector2:
	var movement : Vector2 = Vector2()

	# If move is not bound to one of our controllers,
	# that controller will return `Vector2.ZERO`.
	movement += $LeftHand.get_vector2("move")
	movement += $RightHand.get_vector2("move")

	return movement

# `_process_on_physical_movement` handles the physical movement of the player
# adjusting our character body position to "catch up to" the player.
# If the character body encounters an obstruction our view will black out
# and we will stop further character movement until the player physically
# moves back.
func _process_on_physical_movement(delta: float) -> bool:
	# Remember our current velocity, as we'll apply that later.
	var current_velocity := character_body.velocity

	# Remember where our player body currently is.
	var org_player_body: Vector3 = character_body.global_transform.origin

	# Determine where our player body should be.
	var player_body_location: Vector3 = camera_node.transform * neck_position_node.transform.origin
	player_body_location.y = 0.0
	player_body_location = global_transform * player_body_location

	# Attempt to move our character.
	character_body.velocity = (player_body_location - org_player_body) / delta
	character_body.move_and_slide()

	# Set back to our current value.
	character_body.velocity = current_velocity

	# Check if we managed to move all the way, ignoring height change.
	var movement_left := player_body_location - character_body.global_transform.origin
	movement_left.y = 0.0

	# Check if we managed to move where we wanted to.
	var location_offset := movement_left.length()
	if location_offset > 0.1:
		# We couldn't go where we wanted to, black out our screen.
		black_out.fade = clamp((location_offset - 0.1) / 0.1, 0.0, 1.0)

		return true
	else:
		black_out.fade = 0.0
		return false


func _copy_player_rotation_to_character_body() -> void:
	# We only copy our forward direction to our character body, we ignore tilt.
	var camera_forward := -camera_node.global_transform.basis.z
	var body_forward := Vector3(camera_forward.x, 0.0, camera_forward.z)

	character_body.global_transform.basis = Basis.looking_at(body_forward, Vector3.UP)


# `_process_movement_on_input` handles movement through controller input.
# We first handle rotating the player and then apply movement.
# We also apply the effects of gravity at this point.
func _process_movement_on_input(is_colliding: bool, delta: float) -> void:
	# Remember where our player body currently is.
	var org_player_body: Vector3 = character_body.global_transform.origin

	if not is_colliding:
		# Only handle input if we've not physically moved somewhere we shouldn't.
		var movement_input := _get_movement_input()

		# First handle rotation, to keep this example simple we are implementing
		# "smooth" rotation here. This can lead to motion sickness.
		# Adding a comfort option with "stepped" rotation is good practice but
		# falls outside of the scope of this demonstration.

		var t1 := Transform3D()
		var t2 := Transform3D()
		var rot := Transform3D()

		# We are going to rotate the origin around the player.
		var player_position := character_body.global_transform.origin - global_transform.origin

		t1.origin = -player_position
		t2.origin = player_position
		rot = rot.rotated(Vector3(0.0, 1.0, 0.0), -movement_input.x * delta * rotation_speed)
		global_transform = (global_transform * t2 * rot * t1).orthonormalized()

		# Now ensure our player body is facing the correct way as well.
		_copy_player_rotation_to_character_body()

		# Now handle forward/backwards movement.
		# Straffing can be added by using the movement_input.x input
		# and using a different input for rotational control.
		# Straffing is more prone to motion sickness.
		var direction: Vector3 = (character_body.global_transform.basis * Vector3(0.0, 0.0, -movement_input.y)) * movement_speed
		if direction:
			character_body.velocity.x = move_toward(character_body.velocity.x, direction.x, delta * movement_acceleration)
			character_body.velocity.z = move_toward(character_body.velocity.z, direction.z, delta * movement_acceleration)
		else:
			character_body.velocity.x = move_toward(character_body.velocity.x, 0, delta * movement_acceleration)
			character_body.velocity.z = move_toward(character_body.velocity.z, 0, delta * movement_acceleration)

	# Always handle gravity.
	character_body.velocity.y -= gravity * delta

	# Attempt to move our player.
	character_body.move_and_slide()

	# And now apply the actual movement to our origin.
	global_transform.origin += character_body.global_transform.origin - org_player_body


# _physics_process handles our player movement.
func _physics_process(delta: float) -> void:
	var is_colliding := _process_on_physical_movement(delta)
	_process_movement_on_input(is_colliding, delta)
