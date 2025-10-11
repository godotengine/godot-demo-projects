extends CharacterBody3D

const MOUSE_SENSITIVITY = 2.5
const CAMERA_SMOOTH_SPEED = 10.0
const MOVE_SPEED = 3.0
const FRICTION = 10.0
const JUMP_VELOCITY = 8.0
const BULLET_SPEED = 9.0

const Bullet = preload("res://bullet.tscn")

# Define our FPS and TPS player views using Euler angles.
var _yaw: float = 0.0
var _pitch: float = 0.0

# XZ direction the player is looking at.
var _dir := Vector3(sin(_yaw), 0, cos(_yaw))

# TPS camera.
var _tps_camera_proximity: float = 3.0
var _tps_camera_look_from := Vector3()

enum CameraType {
	CAM_FIXED, ## Fixed camera perspective.
	CAM_FPS, ## First-person perspective.
	CAM_TPS,  ## Third-person perspective.
}

# Current camera type.
# (Note that we toggle this in `_ready()`, so it actually starts with FPS camera.)
var _cam_type := CameraType.CAM_FIXED

var gravity: float = ProjectSettings.get_setting("physics/3d/default_gravity")


func _ready() -> void:
	# Capture the mouse (stops the mouse cursor from showing and ensures it stays within the window).
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED

	# We define the TPS camera in global space by setting it
	# as `top_level` so it ignores the parent transform.
	$Rig/Camera_TPS.top_level = true

	# Perform the logic to create FPS view to start with.
	cycle_camera_type()


func _input(input_event: InputEvent) -> void:
	if input_event is InputEventMouseMotion:
		_yaw -= input_event.screen_relative.x * MOUSE_SENSITIVITY * 0.001
		_pitch += input_event.screen_relative.y * MOUSE_SENSITIVITY * 0.002
		_pitch = clamp(_pitch, -PI, PI)
		$Rig.rotation = Vector3(0, _yaw, 0)


func _update_camera(delta: float) -> void:
	# Keep the player direction up-to-date based on the yaw.
	_dir.x = sin(_yaw)
	_dir.z = cos(_yaw)

	# Rotate the head (and FPS camera and firing origin) with the
	# pitch from the mouse.
	$Rig/Head.rotation = Vector3(_pitch * -0.5, 0, 0)

	match _cam_type:
		CameraType.CAM_TPS:
			# We will focus the TPS camera on the head of the player.
			var target: Vector3 = $Rig/Head.get_global_transform_interpolated().origin

			# Calculate a position to look at the player from.
			var pos := target

			# The camera should be behind the player, so offset the camera relative to direction.
			pos.x += _dir.x * _tps_camera_proximity
			pos.z += _dir.z * _tps_camera_proximity

			# Move the TPS camera up and down depending on the pitch.
			# There's no special formula here, just something that looks okay.
			pos.y += 2.0 + _pitch * _tps_camera_proximity * 0.2

			# Offset from the old `_tps_camera_look_from` to the new position
			# we want the TPS camera to move to.
			var offset: Vector3 = pos - _tps_camera_look_from
			var l: float = offset.length()

			# We cap how far we allow the TPS camera to move on each update,
			# so we get a smooth movement rather than snapping.
			var tps_cam_speed: float = CAMERA_SMOOTH_SPEED * delta

			# If we are trying to move further than the maximum allowed,
			# we resize the offset to `tps_cam_speed`.
			if l > tps_cam_speed:
				offset *= tps_cam_speed / l

			# Move the TPS camera.
			_tps_camera_look_from += offset

			# `look_at_from_position()` does all the magic for us.
			$Rig/Camera_TPS.look_at_from_position(_tps_camera_look_from, target, Vector3(0, 1, 0))

			# For a real TPS camera, some other things to try:
			# - Ray cast from the player towards the camera to prevent it looking through walls.
			#   The SpringArm3D node can be useful here.
			# - Try smoothing the camera by yaw/pitch from the player rather than offset.


func cycle_camera_type() -> void:
	match _cam_type:
		CameraType.CAM_FIXED:
			_cam_type = CameraType.CAM_FPS
			$Rig/Head/Camera_FPS.make_current()
		CameraType.CAM_FPS:
			_cam_type = CameraType.CAM_TPS
			$Rig/Camera_TPS.make_current()
		CameraType.CAM_TPS:
			_cam_type = CameraType.CAM_FIXED
			get_node(^"../Camera_Fixed").make_current()

	# Hide body in FPS view (but keep shadow casting to improve spatial awareness).
	if _cam_type == CameraType.CAM_FPS:
		$Rig/Mesh_Body.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_SHADOWS_ONLY
	else:
		$Rig/Mesh_Body.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_ON


func _process(delta: float) -> void:
	if Input.is_action_just_pressed(&"cycle_camera_type"):
		cycle_camera_type()

	if Input.is_action_just_pressed(&"toggle_physics_interpolation"):
		get_tree().physics_interpolation = not get_tree().physics_interpolation

	if Input.is_action_just_pressed(&"fire"):
		var bullet: RigidBody3D = Bullet.instantiate()

		# Figure out where we want the bullet to spawn.
		# We use a dummy Node offset from the head, but you may want to use e.g.
		# a BoneAttachment3D, or dummy node on a weapon.
		var transform_3d: Transform3D = $Rig/Head/Fire_Origin.get_global_transform_interpolated()
		bullet.position = transform_3d.origin

		# We can calculate the direction the bullet should travel from the basis (rotation)
		# of the dummy Node.
		var bul_dir: Vector3 = transform_3d.basis[2].normalized()

		# Give our physics bullet some starting velocity.
		bullet.linear_velocity = bul_dir * -BULLET_SPEED
		get_parent().add_child(bullet)

		# A moving start for a bullet using physics interpolation can be done
		# by resetting, *then* offsetting the position in the direction of travel.
		# This means that on the first tick the bullet will be moving rather than
		# standing still, as standing still on the first tick can look unnatural.
		bullet.reset_physics_interpolation()
		bullet.position -= bul_dir * (1.0 - Engine.get_physics_interpolation_fraction())


	# If we pressed reset, or went too far from the origin, move back to the origin.
	if Input.is_action_just_pressed(&"reset_position") or position.length() > 10.0:
		position = Vector3(0, 1, 0)
		velocity = Vector3()
		reset_physics_interpolation()
		_yaw = 0.0
		_pitch = 0.0
		$Rig.rotation = Vector3(0, _yaw, 0)

	if Input.is_action_just_pressed(&"jump") and is_on_floor():
		velocity.y += JUMP_VELOCITY

	# We update our camera every frame.
	# Our camera is not physics interpolated, as we want fast response from the mouse.
	# However in the case of first-person and third-person views, the position is indirectly
	# inherited from physics-interpolated player, so we get nice smooth motion while still
	# having quick mouse response.
	_update_camera(delta)


# When physics interpolation is active on the node,
# you should move it on the physics tick (physics_process)
# rather than on the frame (process).
func _physics_process(delta: float) -> void:
	var move := Vector3()

	# Calculate movement relative to the player's coordinate system.
	var input: Vector2 = Input.get_vector(&"move_left", &"move_right", &"move_forward", &"move_backward") * MOVE_SPEED
	move.x = input.x
	move.z = input.y

	# Apply gravity.
	move.y -= gravity * delta

	# Apply mouse rotation to the move, so that it is now in global space.
	move = move.rotated(Vector3(0, 1, 0), _yaw)

	# Apply the global space move to the physics.
	velocity += move

	move_and_slide()

	# Apply friction to horizontal motion in a tick rate-independent manner.
	var friction_delta := exp(-FRICTION * delta)
	velocity = Vector3(velocity.x * friction_delta, velocity.y, velocity.z * friction_delta)
