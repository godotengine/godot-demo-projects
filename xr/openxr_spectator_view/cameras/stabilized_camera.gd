extends Camera3D

## This script allows us to place a camera in the world that provides
## a spectator view where we see what the player sees.
## The positioning is smoothed to create a steadycam type of effect.

## Specify the XRCamera3D node we're replicating the view for.
@export var xr_camera : XRCamera3D

## Remove pitch from our camera orientation?
@export var remove_pitch : bool = true

## Speed at which we lerp, the lower the more stable our camera gets
## at the cost of introducing more lag.
@export_range(1.0, 60.0, 1.0) var lerp_speed : float = 10.0

var prev_camera_transform : Transform3D
var first_frame : bool = true


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if current and xr_camera:
		# Note, we apply our smoothing in the local space of our XROrigin3D node.
		# This way we don't apply smoothing when game logic moves the XROrigin3D node.
		# We only apply smoothing to the physical movement of the player.
		# This makes the spectator view easier to watch by a 3rd party.

		# We smooth out the camera.
		var camera_transform : Transform3D = xr_camera.transform

		if remove_pitch:
			# Remove pitch from camera.
			camera_transform.basis = Basis.looking_at(camera_transform.basis.z, Vector3.UP, true)

		if first_frame:
			first_frame = false
		else:
			# We (s)lerp our physical camera movement to smooth things out
			camera_transform.basis = prev_camera_transform.basis.slerp(camera_transform.basis, delta * lerp_speed)
			camera_transform.origin = prev_camera_transform.origin.lerp(camera_transform.origin, delta * lerp_speed)

		# Update our first person view.
		global_transform = xr_camera.get_parent().global_transform * camera_transform

		# Store camera transform for next frame
		prev_camera_transform = camera_transform
	else:
		# Make sure next time we run through this we don't lerp.
		first_frame = true
