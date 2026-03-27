extends Node3D

## The position of this node will be updated if a camera tracker is available.
@export var tracked_camera : Node3D:
	set(value):
		tracked_camera = value
		if tracked_camera:
			%CameraRemoteTransform3D.remote_path = tracked_camera.get_path()
		else:
			%CameraRemoteTransform3D.remote_path = NodePath()

# Enable the left or right pointer?
var left_or_right: int = 1


# Enable the pointer on the last controller we pressed a button on
func _enable_pointer():
	$XROrigin3D/LeftHandAim/XRPointer.enabled = left_or_right == 0
	$XROrigin3D/RightHandAim/XRPointer.enabled = left_or_right == 1


# Called when the node enters the scene tree for the first time.
func _ready():
	_enable_pointer()


# We pressed a button on our left hand.
func _on_left_hand_aim_button_pressed(_name):
	# Toggle to left hand.
	if left_or_right != 0:
		left_or_right = 0
		_enable_pointer()


# We pressed a button on our right hand.
func _on_right_hand_aim_button_pressed(_name):
	# Toggle to right hand.
	if left_or_right != 1:
		left_or_right = 1
		_enable_pointer()
