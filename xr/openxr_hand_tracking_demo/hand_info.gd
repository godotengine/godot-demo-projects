extends Node3D

@export_enum("Left", "Right") var hand : int = 0

@export var fallback_mesh : Node3D

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	var text = ""

	if hand == 0:
		text += "Left hand\n"
	else:
		text += "Right hand\n"

	var controller_tracker : XRPositionalTracker = XRServer.get_tracker("left_hand" if hand == 0 else "right_hand")
	if controller_tracker:
		var profile = controller_tracker.profile.replace("/interaction_profiles/", "").replace("/", " ")
		text += "\nProfile: " + profile + "\n"

		var pose : XRPose = controller_tracker.get_pose("palm_pose")
		if pose and pose.tracking_confidence != XRPose.XR_TRACKING_CONFIDENCE_NONE:
			text +=" - Using palm pose\n"
		else:
			pose = controller_tracker.get_pose("grip")
			if pose:
				text +=" - Using grip pose\n"

		if pose:
			if pose.tracking_confidence == XRPose.XR_TRACKING_CONFIDENCE_NONE:
				text += "- No tracking data\n"
			elif pose.tracking_confidence == XRPose.XR_TRACKING_CONFIDENCE_LOW:
				text += "- Low confidence tracking data\n"
			elif pose.tracking_confidence == XRPose.XR_TRACKING_CONFIDENCE_HIGH:
				text += "- High confidence tracking data\n"
			else:
				text += "- Unknown tracking data %d \n" % [ pose.tracking_confidence ]
		else:
			text += "- No pose data\n"
	else:
		text += "\nNo controller tracker found!\n"

	var hand_tracker : XRHandTracker = XRServer.get_tracker("/user/hand_tracker/left" if hand == 0 else "/user/hand_tracker/right")
	if hand_tracker:
		text += "\nHand tracker found\n"

		# Report data source specified
		if hand_tracker.hand_tracking_source == XRHandTracker.HAND_TRACKING_SOURCE_UNKNOWN:
			text += "- Source: unknown\n"
		elif hand_tracker.hand_tracking_source == XRHandTracker.HAND_TRACKING_SOURCE_UNOBSTRUCTED:
			text += "- Source: optical hand tracking\n"
		elif hand_tracker.hand_tracking_source == XRHandTracker.HAND_TRACKING_SOURCE_CONTROLLER:
			text += "- Source: inferred from controller\n"
		elif hand_tracker.hand_tracking_source == XRHandTracker.HAND_TRACKING_SOURCE_NOT_TRACKED:
			text += "- Source: no source\n"
		else:
			text += "- Source: %d\n" % [ hand_tracker.hand_tracking_source ]

		# If we're not tracking, show our fallback mesh on our controller tracking.
		# If we're also not controller tracking, we can't show anything.
		# Note: this is only a sphere in this example.
		if fallback_mesh:
			fallback_mesh.visible = not hand_tracker.has_tracking_data
	else:
		text += "\nNo hand tracker found!\n"

	$Info.text = text
