extends Node3D

var xr_interface : OpenXRInterface

# Called when the node enters the scene tree for the first time.
func _ready():
	xr_interface = XRServer.find_interface("OpenXR")
	if xr_interface and xr_interface.is_initialized():
		var vp = get_viewport()

		# Enable XR on the main viewport
		vp.use_xr = true

		# Make sure v-sync is disabled, we're using the headsets v-sync
		DisplayServer.window_set_vsync_mode(DisplayServer.VSYNC_DISABLED)

		$XROrigin3D/HandJoints.set_xr_interface(xr_interface)



func _on_xr_controller_3d_left_button_pressed(name):
	print("_on_xr_controller_3d_left_button_pressed ", name)


