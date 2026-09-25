extends Node3D


# If true passthrough is enabled.
var _passthrough_enabled: bool = false

@onready var start_xr = $StartXR
@onready var world_environment: WorldEnvironment = $WorldEnvironment

## Call to enable or disable passthrough.
func enable_passthrough(enable: bool) -> void:
	if _passthrough_enabled == enable:
		return

	var xr_interface: OpenXRInterface = start_xr.xr_interface
	var vp: Viewport = get_viewport()
	var environment: Environment = world_environment.environment

	_passthrough_enabled = enable
	if _passthrough_enabled:
		xr_interface.environment_blend_mode = XRInterface.XR_ENV_BLEND_MODE_ALPHA_BLEND
		vp.transparent_bg = true
		environment.background_mode = Environment.BG_COLOR
		environment.background_color = Color(0.0, 0.0, 0.0, 0.0)
	else:
		xr_interface.environment_blend_mode = XRInterface.XR_ENV_BLEND_MODE_OPAQUE
		vp.transparent_bg = false
		environment.background_mode = Environment.BG_SKY


# This method is called when our OpenXR session has successfully begun.
# This means our application is ready to output to the headset.
func _on_start_xr_session_begun():
	enable_passthrough(true)
