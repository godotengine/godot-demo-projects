class_name XRHandFallbackModifier3D
extends SkeletonModifier3D

## This node implements a fallback if the hand tracking API is not available
## or if one of the data sources is not supported by the XR runtime.
## It uses trigger and grip inputs from the normal controller tracker to
## animate the index finger and bottom 3 fingers respectively.

## Action to use for animating index finger.
@export var trigger_action : String = "trigger"

## Action to use for animating bottom 3 fingers.
@export var grip_action : String = "grip"

# Called by our skeleton logic when this modifier needs to apply its modifications.
func _process_modification() -> void:
	# Get our skeleton.
	var skeleton: Skeleton3D = get_skeleton()
	if !skeleton:
		return

	# Find our parent controller
	var parent = get_parent()
	while parent and not parent is XRNode3D:
		parent = parent.get_parent()
	if !parent:
		return

	# Check if we have an active hand tracker,
	# if so, we don't need our fallback!
	var xr_parent : XRNode3D = parent
	if not xr_parent.tracker in [ "left_hand", "right_hand" ]:
		return

	var trigger : float = 0.0
	var grip : float = 0.0

	# Check our tracker for trigger and grip values
	var tracker : XRControllerTracker = XRServer.get_tracker(xr_parent.tracker)
	if tracker:
		var trigger_value : Variant = tracker.get_input(trigger_action)
		if trigger_value:
			trigger = trigger_value

		var grip_value : Variant = tracker.get_input(grip_action)
		if grip_value:
			grip = grip_value

	# Now position bones
	var bone_count = skeleton.get_bone_count()
	for i in bone_count:
		var t : Transform3D = skeleton.get_bone_rest(i)

		# We animate based on bone_name.
		# For now just hardcoded values.
		# Note that we position all bones in case we need to reset some.
		var bone_name = skeleton.get_bone_name(i)
		if bone_name == "LeftHand":
			# Offset to center our palm, this requires the use of the palm pose!
			t.origin += Vector3(-0.015, 0.0, 0.04)
		elif bone_name == "RightHand":
			# Offset to center our palm, this requires the use of the palm pose!
			t.origin += Vector3(0.015, 0.0, 0.04)
		elif bone_name == "LeftIndexDistal" or bone_name == "LeftIndexIntermediate" \
			or bone_name == "RightIndexDistal" or bone_name == "RightIndexIntermediate":
			var r : Transform3D
			t = t * r.rotated(Vector3(1.0, 0.0, 0.0), deg_to_rad(45.0) * trigger)
		elif bone_name == "LeftIndexProximal" or bone_name == "RightIndexProximal":
			var r : Transform3D
			t = t * r.rotated(Vector3(1.0, 0.0, 0.0), deg_to_rad(20.0) * trigger)
		elif bone_name == "LeftMiddleDistal" or bone_name == "LeftMiddleIntermediate" or bone_name == "LeftMiddleProximal" \
			or bone_name == "RightMiddleDistal" or bone_name == "RightMiddleIntermediate" or bone_name == "RightMiddleProximal" \
			or bone_name == "LeftRingDistal" or bone_name == "LeftRingIntermediate" or bone_name == "LeftRingProximal" \
			or bone_name == "RightRingDistal" or bone_name == "RightRingIntermediate" or bone_name == "RightRingProximal" \
			or bone_name == "LeftLittleDistal" or bone_name == "LeftLittleIntermediate" or bone_name == "LeftLittleProximal" \
			or bone_name == "RightLittleDistal" or bone_name == "RightLittleIntermediate" or bone_name == "RightLittleProximal":
			var r : Transform3D
			t = t * r.rotated(Vector3(1.0, 0.0, 0.0), deg_to_rad(90.0) * grip)

		skeleton.set_bone_pose(i, t)
