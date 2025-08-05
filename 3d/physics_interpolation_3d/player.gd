extends CharacterBody3D

# Define our FPS and TPS player views using Euler angles.
var _yaw : float = 0
var _pitch = 0

# XZ direction the player is looking at.
var _direction = Vector3(-sin(_yaw), 0, -cos(_yaw))

# TPS Camera.
var _tps_camera_proximity = 3
var _tps_camera_look_from = Vector3()

# Fixed camera, first person shooter, third person shooter.
enum CameraType {CAM_FIXED, CAM_FPS, CAM_TPS}

# Current camera type.
# (Note we toggle this in _ready() so it actually starts with FPS camera.)
var _cam_type = CameraType.CAM_FIXED

var _bullet_scene = load("res://bullet.tscn")

func _ready():
	# Capture the mouse, stop the cursor showing.
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	
	# We define the TPS camera in global space by setting it
	# as top_level so it ignores the parent transform.
	$Rig/Camera_TPS.set_as_top_level(true)
	
	# Perform the logic to create FPS view to start with.
	toggle_camera_type()

# Input can come in freely at any point during the frame or tick.
# We use this to transform the player rig immediately (so no lag),
# but this means we should turn off physics interpolation for the rig
# (we use the physics_interpolation_mode in the inspector, but the mode
# can also be changed via script).
func _input(event: InputEvent) -> void:
	if event is InputEventMouseMotion:
		_yaw -= event.relative.x * 0.005 # How much we react to left right mouse.
		_pitch += event.relative.y * 0.01 # How much we react to up down mouse.
		_pitch = clamp(_pitch, -PI, PI) # Don't look higher or lower than 90 degrees.
		
		# Apply only the yaw to the rig (we don't want the body mesh to change pitch).
		# Pitch is handled separately.
		$Rig.rotation = Vector3(0, _yaw, 0)
		
func _update_camera(_delta: float):
		# Keep the player direction up to date based on the yaw.
		_direction.x = -sin(_yaw)
		_direction.z = -cos(_yaw)

		# Rotate the head (and FPS camera and firing origin) with the
		# pitch from the mouse.
		$Rig/Head.rotation = Vector3(_pitch * -0.5, 0, 0)
	
		if _cam_type == CameraType.CAM_TPS:
			# We will focus the TPS camera on the head of the player.
			var target = $Rig/Head.get_global_transform_interpolated().origin
			
			# Calculate a position to look at the player from.
			var pos = target
			
			# The camera should be behind the player, so reverse the polarity
			# of direction.
			pos.x -= _direction.x * _tps_camera_proximity
			pos.z -= _direction.z * _tps_camera_proximity
			
			# Move the TPS camera up and down depending on the pitch.
			# There's no special formula here, just something that looks okay.
			pos.y += 2.0 + (_pitch * (0.2 * _tps_camera_proximity))
			
			# Offset from the old _tps_camera_look_from to the new position
			# we want the TPS camera to move to.
			var offset = pos - _tps_camera_look_from
			var l = offset.length()
			
			# We cap how far we allow the TPS camera to move on each update,
			# so we get a smooth movement, rather than snapping.
			var tps_cam_speed = _delta * 8.0
			
			# If we are trying to move further than the maximum allowed,
			# we resize the offset to tps_cam_speed.
			if (l > tps_cam_speed):
				offset *= tps_cam_speed / l
			
			# Move the TPS camera.
			_tps_camera_look_from += offset 
			
			# The look_at_from_position does all the magic for us.
			$Rig/Camera_TPS.look_at_from_position(_tps_camera_look_from, target, Vector3(0, 1, 0))
			
			# For a real TPS camera some other things to try:
			# * Ray cast from the player towards the camera to prevent it looking through walls.
			# * Try smoothing the camera by yaw / pitch from the player rather than offset.

func toggle_camera_type():
	match _cam_type:
		CameraType.CAM_FIXED:
			_cam_type = CameraType.CAM_FPS
			$Rig/Head/Camera_FPS.make_current()
		CameraType.CAM_FPS:
			_cam_type = CameraType.CAM_TPS
			$Rig/Camera_TPS.make_current()
		CameraType.CAM_TPS:
			_cam_type = CameraType.CAM_FIXED
			get_node("../Camera_Fixed").make_current()
		
	# Hide body in FPS view, show in all other views.
	$Rig/Mesh_Body.visible = _cam_type != CameraType.CAM_FPS

func _process(_delta: float) -> void:
	# Allow selecting different cameras.
	if (Input.is_action_just_pressed("ui_focus_next")):
		toggle_camera_type()
	
	if (Input.is_action_just_pressed("fire")):
		# Create a bullet...
		var bul = _bullet_scene.instantiate()
		
		# Figure out where we want the bullet to spawn.
		# We use a dummy Node offset from the head, but you may want to use e.g.
		# a bone attachment, or dummy node on a weapon.
		var tr : Transform3D = $Rig/Head/Fire_Origin.get_global_transform_interpolated()
		bul.position = tr.origin
		
		# We can calculate the direction the bullet should travel from the basis (rotation)
		# of the dummy Node.
		var bul_dir = tr.basis[2].normalized()
		
		# Let's give our physics bullet some velocity.
		bul.linear_velocity = bul_dir * -9
		get_node("..").add_child(bul)

		# A moving start for a bullet using physics interpolation can be done
		# by resetting, THEN offsetting the position in the direction of travel.
		# This means that on the first tick the bullet will be moving rather than
		# standing still, which can look unnatural.
		bul.reset_physics_interpolation()
		bul.position -= bul_dir * (1.0 - Engine.get_physics_interpolation_fraction())
	
	
	# If we pressed reset, or too far from the origin... move the player back to origin.
	if (Input.is_action_just_pressed("ui_accept") or position.length() > 10):
		position = Vector3(0, 1, 0)
		velocity = Vector3()
		reset_physics_interpolation()
		_yaw = 0
		_pitch = 0

	if (Input.is_action_just_pressed("jump")) and is_on_floor():
		velocity += Vector3(0, 12, 0)

	# We update our camera every frame.
	# Our camera is not physics interpolated, as we want fast response from the mouse.
	# However in the case of FPS and TPS, the position is indirectly inherited from
	# the physics interpolated player, so we get nice smooth motion, but quick mouse
	# response.
	_update_camera(_delta)
	
# When physics interpolation is active on the node,
# you should move it on the physics tick (physics_process)
# rather than on the frame (process).
func _physics_process(_delta: float) -> void:
	
	var move : Vector3 = Vector3()
	
	# Let us calculate a move relative to the player coordinate system.
	if Input.is_action_pressed("ui_up"):
		move.z -= 1
	if Input.is_action_pressed("ui_down"):
		move.z += 1
	if Input.is_action_pressed("ui_left"):
		move.x -= 1
	if Input.is_action_pressed("ui_right"):
		move.x += 1
	
	# Apply some gravity.
	move.y -= 0.9
	
	# Apply mouse rotation to the move, so that it is now in global space.
	move = move.rotated(Vector3(0, 1, 0), _yaw)
	
	# Apply the global space move to the physics.
	velocity += move
	
	move_and_slide()
	
	# Apply some friction.
	velocity *= 0.9
