extends Node3D

signal focus_lost
signal focus_gained
signal pose_recentered

@export var maximum_refresh_rate : int = 90

var xr_interface : OpenXRInterface
var xr_is_focused := false


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	xr_interface = XRServer.find_interface("OpenXR")
	if xr_interface and xr_interface.is_initialized():
		print("OpenXR instantiated successfully.")
		var vp : Viewport = get_viewport()

		# Enable XR on our viewport.
		vp.use_xr = true

		# Make sure V-Sync is off, as V-Sync is handled by OpenXR.
		DisplayServer.window_set_vsync_mode(DisplayServer.VSYNC_DISABLED)

		# Enable variable rate shading.
		if RenderingServer.get_rendering_device():
			vp.vrs_mode = Viewport.VRS_XR
		elif int(ProjectSettings.get_setting("xr/openxr/foveation_level")) == 0:
			push_warning("OpenXR: Recommend setting Foveation level to High in Project Settings")

		# Connect the OpenXR events.
		xr_interface.session_begun.connect(_on_openxr_session_begun)
		xr_interface.session_visible.connect(_on_openxr_visible_state)
		xr_interface.session_focussed.connect(_on_openxr_focused_state)
		xr_interface.session_stopping.connect(_on_openxr_stopping)
		xr_interface.pose_recentered.connect(_on_openxr_pose_recentered)
	else:
		# We couldn't start OpenXR.
		print("OpenXR not instantiated!")
		get_tree().quit()


# Handle OpenXR session ready.
func _on_openxr_session_begun() -> void:
	# Get the reported refresh rate.
	var current_refresh_rate := xr_interface.get_display_refresh_rate()
	if current_refresh_rate > 0:
		print("OpenXR: Refresh rate reported as ", str(current_refresh_rate))
	else:
		print("OpenXR: No refresh rate given by XR runtime")

	# See if we have a better refresh rate available.
	var new_rate := current_refresh_rate
	var available_rates: Array[float]
	available_rates.assign(xr_interface.get_available_display_refresh_rates())
	if available_rates.is_empty():
		print("OpenXR: Target does not support refresh rate extension")
	elif available_rates.size() == 1:
		# Only one available, so use it.
		new_rate = available_rates[0]
	else:
		for rate in available_rates:
			if rate > new_rate and rate <= maximum_refresh_rate:
				new_rate = rate

	# Did we find a better rate?
	if current_refresh_rate != new_rate:
		print("OpenXR: Setting refresh rate to ", str(new_rate))
		xr_interface.set_display_refresh_rate(new_rate)
		current_refresh_rate = new_rate

	# Now match our physics rate. This is currently needed to avoid jittering,
	# due to physics interpolation not being used.
	Engine.physics_ticks_per_second = roundi(current_refresh_rate)


# Handle OpenXR visible state.
func _on_openxr_visible_state() -> void:
	# We always pass this state at startup,
	# but the second time we get this, it means our player took off their headset.
	if xr_is_focused:
		print("OpenXR lost focus")

		xr_is_focused = false

		# Pause our game.
		process_mode = Node.PROCESS_MODE_DISABLED

		focus_lost.emit()


# Handle OpenXR focused state
func _on_openxr_focused_state() -> void:
	print("OpenXR gained focus")
	xr_is_focused = true

	# Unpause our game.
	process_mode = Node.PROCESS_MODE_INHERIT

	focus_gained.emit()


# Handle OpenXR stopping state.
func _on_openxr_stopping() -> void:
	# Our session is being stopped.
	print("OpenXR is stopping")


# Handle OpenXR pose recentered signal.
func _on_openxr_pose_recentered() -> void:
	# User recentered view, we have to react to this by recentering the view.
	# This is game implementation dependent.
	pose_recentered.emit()
