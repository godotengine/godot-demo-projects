extends XRNode3D

## Detect which tracker we should use to position our hand, we prefer
## hand tracking as this works in unison with our hand skeleton updates.

## Hand for which to get our tracking data.
@export_enum("Left","Right") var hand : int = 0

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	var new_tracker : String

	# Check if our hand tracker is usable
	new_tracker = "/user/hand_tracker/left" if hand == 0 \
		else "/user/hand_tracker/right"
	var hand_tracker : XRHandTracker = XRServer.get_tracker(new_tracker)
	if hand_tracker and hand_tracker.has_tracking_data:
		if tracker != new_tracker:
			print("Switching to left hand tracker" if hand == 0 \
				else "Switching to right hand tracker")
			tracker = new_tracker
			pose = "default"

		return

	# Else fallback to our controller tracker
	new_tracker = "left_hand" if hand == 0 else "right_hand"
	var controller_tracker : XRControllerTracker = XRServer.get_tracker(new_tracker)
	if controller_tracker:
		if tracker != new_tracker:
			print("Switching to left controller tracker" if hand == 0 \
				else "Switching to right controller tracker")
			tracker = new_tracker

		var new_pose : String = "palm_pose"
		var xr_pose : XRPose = controller_tracker.get_pose(new_pose)
		if not xr_pose or xr_pose.tracking_confidence == XRPose.XR_TRACKING_CONFIDENCE_NONE:
			new_pose = "grip"

		if pose != new_pose:
			pose = new_pose
