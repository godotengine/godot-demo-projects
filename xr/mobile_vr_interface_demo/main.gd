extends Node3D

var xr_interface : MobileVRInterface

# Called when the node enters the scene tree for the first time.
func _ready():
	xr_interface = XRServer.find_interface("Native mobile")
	if xr_interface and xr_interface.initialize():
		# Disable lens distortion.
		# xr_interface.k1 = 0.0
		# xr_interface.k2 = 0.0

		# setup viewport
		var vp = get_viewport()
		vp.use_xr = true
		vp.vrs_mode = Viewport.VRS_XR
	else:
		# How did we get here?
		get_tree().quit()

func _process(delta):
	var dir : Vector2 = Vector2()

	if Input.is_action_pressed("ui_left"):
		dir.x = -1.0
	elif Input.is_action_pressed("ui_right"):
		dir.x = 1.0
	if Input.is_action_pressed("ui_up"):
		dir.y = -1.0
	elif Input.is_action_pressed("ui_down"):
		dir.y = 1.0

	$XROrigin3D.global_position += $XROrigin3D.global_transform.basis.x * dir.x * delta
	$XROrigin3D.global_position += $XROrigin3D.global_transform.basis.z * dir.y * delta
