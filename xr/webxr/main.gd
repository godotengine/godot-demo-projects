extends Node3D

var webxr_interface: XRInterface
var vr_supported: bool = false


func _ready() -> void:
	$CanvasLayer/EnterVRButton.pressed.connect(self._on_enter_vr_button_pressed)

	webxr_interface = XRServer.find_interface("WebXR")
	if webxr_interface:
		# WebXR uses a lot of asynchronous callbacks, so we connect to various
		# signals in order to receive them.
		webxr_interface.session_supported.connect(self._webxr_session_supported)
		webxr_interface.session_started.connect(self._webxr_session_started)
		webxr_interface.session_ended.connect(self._webxr_session_ended)
		webxr_interface.session_failed.connect(self._webxr_session_failed)

		webxr_interface.select.connect(self._webxr_on_select)
		webxr_interface.selectstart.connect(self._webxr_on_select_start)
		webxr_interface.selectend.connect(self._webxr_on_select_end)

		webxr_interface.squeeze.connect(self._webxr_on_squeeze)
		webxr_interface.squeezestart.connect(self._webxr_on_squeeze_start)
		webxr_interface.squeezeend.connect(self._webxr_on_squeeze_end)

		# This returns immediately - our _webxr_session_supported() method
		# (which we connected to the "session_supported" signal above) will
		# be called sometime later to let us know if it's supported or not.
		webxr_interface.is_session_supported("immersive-vr")

	$XROrigin3D/LeftController.button_pressed.connect(self._on_left_controller_button_pressed)
	$XROrigin3D/LeftController.button_released.connect(self._on_left_controller_button_released)


func _webxr_session_supported(session_mode: String, supported: bool) -> void:
	if session_mode == 'immersive-vr':
		vr_supported = supported


func _on_enter_vr_button_pressed() -> void:
	if not vr_supported:
		OS.alert("Your browser doesn't support VR")
		return

	# We want an immersive VR session, as opposed to AR ('immersive-ar') or a
	# simple 3DoF viewer ('viewer').
	webxr_interface.session_mode = 'immersive-vr'
	# 'bounded-floor' is room scale, 'local-floor' is a standing or sitting
	# experience (it puts you 1.6m above the ground if you have 3DoF headset),
	# whereas as 'local' puts you down at the XROrigin3D.
	# This list means it'll first try to request 'bounded-floor', then
	# fallback on 'local-floor' and ultimately 'local', if nothing else is
	# supported.
	webxr_interface.requested_reference_space_types = 'bounded-floor, local-floor, local'
	# In order to use 'local-floor' or 'bounded-floor' we must also
	# mark the features as required or optional.
	webxr_interface.required_features = 'local-floor'
	webxr_interface.optional_features = 'bounded-floor'

	# This will return false if we're unable to even request the session,
	# however, it can still fail asynchronously later in the process, so we
	# only know if it's really succeeded or failed when our
	# _webxr_session_started() or _webxr_session_failed() methods are called.
	if not webxr_interface.initialize():
		OS.alert("Failed to initialize WebXR")
		return


func _webxr_session_started() -> void:
	$CanvasLayer.visible = false
	# This tells Godot to start rendering to the headset.
	get_viewport().use_xr = true
	# This will be the reference space type you ultimately got, out of the
	# types that you requested above. This is useful if you want the game to
	# work a little differently in 'bounded-floor' versus 'local-floor'.
	print ("Reference space type: " + webxr_interface.reference_space_type)
	# This will be the list of features that were successfully enabled
	# (except on browsers that don't support this property).
	print("Enabled features: ", webxr_interface.enabled_features)


func _webxr_session_ended() -> void:
	$CanvasLayer.visible = true
	# If the user exits immersive mode, then we tell Godot to render to the web
	# page again.
	get_viewport().use_xr = false


func _webxr_session_failed(message: String) -> void:
	OS.alert("Failed to initialize: " + message)


func _on_left_controller_button_pressed(button: String) -> void:
	print ("Button pressed: " + button)


func _on_left_controller_button_released(button: String) -> void:
	print ("Button release: " + button)


func _process(_delta: float) -> void:
	var thumbstick_vector: Vector2 = $XROrigin3D/LeftController.get_vector2("thumbstick")
	if thumbstick_vector != Vector2.ZERO:
		print ("Left thumbstick position: " + str(thumbstick_vector))


func _webxr_on_select(input_source_id: int) -> void:
	print("Select: " + str(input_source_id))

	var tracker: XRPositionalTracker = webxr_interface.get_input_source_tracker(input_source_id)
	var xform = tracker.get_pose('default').transform
	print (xform.origin)


func _webxr_on_select_start(input_source_id: int) -> void:
	print("Select Start: " + str(input_source_id))


func _webxr_on_select_end(input_source_id: int) -> void:
	print("Select End: " + str(input_source_id))


func _webxr_on_squeeze(input_source_id: int) -> void:
	print("Squeeze: " + str(input_source_id))


func _webxr_on_squeeze_start(input_source_id: int) -> void:
	print("Squeeze Start: " + str(input_source_id))


func _webxr_on_squeeze_end(input_source_id: int) -> void:
	print("Squeeze End: " + str(input_source_id))
