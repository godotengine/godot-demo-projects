extends Node3D

@onready var viewport: Viewport = get_viewport()
@onready var environment: Environment = $WorldEnvironment.environment
@onready var fade_message : FadeMessage3D = $XROrigin3D/FadeMessage3D

var passthrough_enabled: bool = false

## Switch to AR (passthrough)
func switch_to_ar() -> bool:
	var xr_interface: OpenXRInterface = $StartVR.get_xr_interface()
	if not xr_interface:
		return false

	var modes = xr_interface.get_supported_environment_blend_modes()
	if XRInterface.XR_ENV_BLEND_MODE_ALPHA_BLEND in modes:
		xr_interface.environment_blend_mode = XRInterface.XR_ENV_BLEND_MODE_ALPHA_BLEND
	elif XRInterface.XR_ENV_BLEND_MODE_ADDITIVE in modes:
		xr_interface.environment_blend_mode = XRInterface.XR_ENV_BLEND_MODE_ADDITIVE
	else:
		push_error("Passthrough not supported!")
		fade_message.text = "Passthrough is not supported on this device"
		return false

	viewport.transparent_bg = true
	environment.background_mode = Environment.BG_COLOR
	environment.background_color = Color(0.0, 0.0, 0.0, 0.0)
	return true


## Switch to VR (exit passthrough)
func switch_to_vr() -> bool:
	var xr_interface: OpenXRInterface = $StartVR.get_xr_interface()
	if not xr_interface:
		return false

	var modes = xr_interface.get_supported_environment_blend_modes()
	if XRInterface.XR_ENV_BLEND_MODE_OPAQUE in modes:
		xr_interface.environment_blend_mode = XRInterface.XR_ENV_BLEND_MODE_OPAQUE
	else:
		push_error("Opaque not supported!")
		fade_message.text = "Opaque mode is not supported on this device"
		return false

	viewport.transparent_bg = false
	environment.background_mode = Environment.BG_SKY
	return true


# Called when our OpenXR session has started.
func _on_start_vr_session_started():
	# Make sure we're in passthrough mode.
	passthrough_enabled = switch_to_ar()


# Called when a button is pressed on either controller.
func _on_button_released(action_name):
	if action_name == "ax_button":
		# Toggle passthrough
		if passthrough_enabled:
			switch_to_vr()
			passthrough_enabled = false
		else:
			passthrough_enabled = switch_to_ar()
