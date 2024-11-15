extends CharacterBody3D

# Settings to control the character.
@export var rotation_speed := 1.0
@export var movement_speed := 5.0
@export var movement_acceleration := 5.0

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity := float(ProjectSettings.get_setting("physics/3d/default_gravity"))

# Helper variables to keep our code readable.
@onready var origin_node: XROrigin3D = $XROrigin3D
@onready var camera_node: XRCamera3D = $XROrigin3D/XRCamera3D
@onready var neck_position_node: Node3D = $XROrigin3D/XRCamera3D/Neck
@onready var black_out: Node3D = $XROrigin3D/XRCamera3D/BlackOut

## Called when the user has requested their view to be recentered.
func recenter() -> void:
	var xr_interface: OpenXRInterface = XRServer.find_interface("OpenXR")
	if not xr_interface:
		push_error("Couldn't access OpenXR interface!")
		return

	var play_area_mode: XRInterface.PlayAreaMode = xr_interface.get_play_area_mode()
	if play_area_mode == XRInterface.XR_PLAY_AREA_SITTING:
		push_warning("Sitting play space is not suitable for this setup.")
	elif play_area_mode == XRInterface.XR_PLAY_AREA_ROOMSCALE:
		# This is already handled by the headset.
		pass
	else:
		# Use Godot's own logic.
		XRServer.center_on_hmd(XRServer.RESET_BUT_KEEP_TILT, true)

	# XRCamera3D node won't be updated yet, so go straight to the source!
	var head_tracker: XRPositionalTracker = XRServer.get_tracker("head")
	if not head_tracker:
		push_error("Couldn't locate head tracker!")
		return

	var pose: XRPose = head_tracker.get_pose("default")
	var head_transform: Transform3D = pose.get_adjusted_transform()

	# Get neck transform in XROrigin3D space
	var neck_transform: Transform3D = neck_position_node.transform * head_transform

	# Reset our XROrigin transform and apply the inverse of the neck position.
	var new_origin_transform: Transform3D = Transform3D()
	new_origin_transform.origin.x = -neck_transform.origin.x
	new_origin_transform.origin.y = 0.0
	new_origin_transform.origin.z = -neck_transform.origin.z
	origin_node.transform = new_origin_transform

	# Finally reset character orientation
	transform.basis = Basis()

# Returns our move input by querying the move action on each controller.
func _get_movement_input() -> Vector2:
	var movement := Vector2()

	# If move is not bound to one of our controllers,
	# that controller will return `Vector2.ZERO`.
	movement += $XROrigin3D/LeftHand.get_vector2("move")
	movement += $XROrigin3D/RightHand.get_vector2("move")

	return movement

# `_process_on_physical_movement()` handles the physical movement of the player
# adjusting our character body position to "catch up to" the player.
# If the character body encounters an obstruction our view will black out
# and we will stop further character movement until the player physically
# moves back.
func _process_on_physical_movement(delta: float) -> bool:
	# Remember our current velocity, as we'll apply that later.
	var current_velocity := velocity

	# Start by rotating the player to face the same way our real player is.
	var camera_basis: Basis = origin_node.transform.basis * camera_node.transform.basis
	var forward: Vector2 = Vector2(camera_basis.z.x, camera_basis.z.z)
	var angle: float = forward.angle_to(Vector2(0.0, 1.0))

	# Rotate our character body.
	transform.basis = transform.basis.rotated(Vector3.UP, angle)

	# Reverse this rotation our origin node.
	origin_node.transform = Transform3D().rotated(Vector3.UP, -angle) * origin_node.transform

	# Now apply movement, first move our player body to the right location.
	var org_player_body: Vector3 = global_transform.origin
	var player_body_location: Vector3 = origin_node.transform * camera_node.transform * neck_position_node.transform.origin
	player_body_location.y = 0.0
	player_body_location = global_transform * player_body_location

	velocity = (player_body_location - org_player_body) / delta
	move_and_slide()

	# Now move our XROrigin back.
	var delta_movement := global_transform.origin - org_player_body
	origin_node.global_transform.origin -= delta_movement

	# Negate any height change in local space due to player hitting ramps, etc.
	origin_node.transform.origin.y = 0.0

	# Return our value.
	velocity = current_velocity

	# Check if we managed to move where we wanted to.
	var location_offset := (player_body_location - global_transform.origin).length()
	if location_offset > 0.1:
		# We couldn't go where we wanted to, black out our screen.
		black_out.fade = clampf((location_offset - 0.1) / 0.1, 0.0, 1.0)
		return true
	else:
		black_out.fade = 0.0
		return false

# `_process_movement_on_input()` handles movement through controller input.
# We first handle rotating the player and then apply movement.
# We also apply the effects of gravity at this point.
func _process_movement_on_input(is_colliding: bool, delta: float) -> void:
	if not is_colliding:
		# Only handle input if we've not physically moved somewhere we shouldn't.
		var movement_input := _get_movement_input()

		# First handle rotation, to keep this example simple we are implementing
		# "smooth" rotation here. This can lead to motion sickness.
		# Adding a comfort option with "stepped" rotation is good practice but
		# falls outside of the scope of this demonstration.
		rotation.y += -movement_input.x * delta * rotation_speed

		# Now handle forward/backwards movement.
		# Straffing can be added by using the movement_input.x input
		# and using a different input for rotational control.
		# Straffing is more prone to motion sickness.
		var direction := global_transform.basis * Vector3(0.0, 0.0, -movement_input.y) * movement_speed
		if direction:
			velocity.x = move_toward(velocity.x, direction.x, delta * movement_acceleration)
			velocity.z = move_toward(velocity.z, direction.z, delta * movement_acceleration)
		else:
			velocity.x = move_toward(velocity.x, 0, delta * movement_acceleration)
			velocity.z = move_toward(velocity.z, 0, delta * movement_acceleration)

	# Always handle gravity
	velocity.y -= gravity * delta

	move_and_slide()

# `_physics_process()` handles our player movement.
func _physics_process(delta: float) -> void:
	var is_colliding := _process_on_physical_movement(delta)
	_process_movement_on_input(is_colliding, delta)
