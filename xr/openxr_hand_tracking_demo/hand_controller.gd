extends XRController3D

# Check if we can use our palm pose or should fallback to our grip pose.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	var controller_tracker : XRControllerTracker = XRServer.get_tracker(tracker)
	if controller_tracker:
		var new_pose : String = "palm_pose"
		var xr_pose : XRPose = controller_tracker.get_pose(new_pose)
		if not xr_pose or xr_pose.tracking_confidence == XRPose.XR_TRACKING_CONFIDENCE_NONE:
			new_pose = "grip"

		if pose != new_pose:
			pose = new_pose
