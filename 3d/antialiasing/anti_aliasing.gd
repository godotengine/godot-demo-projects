extends Node

const ROT_SPEED = 0.003
const ZOOM_SPEED = 0.125
const MAIN_BUTTONS = MOUSE_BUTTON_MASK_LEFT | MOUSE_BUTTON_MASK_RIGHT | MOUSE_BUTTON_MASK_MIDDLE

var tester_index := 0
var rot_x := -TAU / 16  # This must be kept in sync with RotationX.
var rot_y := TAU / 8  # This must be kept in sync with CameraHolder.
var camera_distance := 2.0
var base_height := int(ProjectSettings.get_setting("display/window/size/viewport_height"))

@onready var testers: Node3D = $Testers
@onready var camera_holder: Node3D = $CameraHolder  # Has a position and rotates on Y.
@onready var rotation_x: Node3D = $CameraHolder/RotationX
@onready var camera: Camera3D = $CameraHolder/RotationX/Camera3D
@onready var fps_label: Label = $FPSLabel

func _ready() -> void:
	# Disable V-Sync to uncap framerate on supported platforms. This makes performance comparison
	# easier on high-end machines that easily reach the monitor's refresh rate.
	DisplayServer.window_set_vsync_mode(DisplayServer.VSYNC_DISABLED)
	camera_holder.transform.basis = Basis.from_euler(Vector3(0, rot_y, 0))
	rotation_x.transform.basis = Basis.from_euler(Vector3(rot_x, 0, 0))
	update_gui()
	get_viewport().size_changed.connect(_on_viewport_size_changed)


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed(&"ui_left"):
		_on_previous_pressed()
	if event.is_action_pressed(&"ui_right"):
		_on_next_pressed()

	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_WHEEL_UP:
			camera_distance -= ZOOM_SPEED
		if event.button_index == MOUSE_BUTTON_WHEEL_DOWN:
			camera_distance += ZOOM_SPEED
		camera_distance = clamp(camera_distance, 1.5, 6)

	if event is InputEventMouseMotion and event.button_mask & MAIN_BUTTONS:
		# Compensate motion speed to be resolution-independent (based on the window height).
		var relative_motion: Vector2 = event.relative * DisplayServer.window_get_size().y / base_height
		rot_y -= relative_motion.x * ROT_SPEED
		rot_x -= relative_motion.y * ROT_SPEED
		rot_x = clamp(rot_x, -1.57, 0)
		camera_holder.transform.basis = Basis.from_euler(Vector3(0, rot_y, 0))
		rotation_x.transform.basis = Basis.from_euler(Vector3(rot_x, 0, 0))


func _process(delta: float) -> void:
	var current_tester: Node3D = testers.get_child(tester_index)
	# This code assumes CameraHolder's X and Y coordinates are already correct.
	var current_position := camera_holder.global_transform.origin.z
	var target_position := current_tester.global_transform.origin.z
	camera_holder.global_transform.origin.z = lerpf(current_position, target_position, 3 * delta)
	camera.position.z = lerpf(camera.position.z, camera_distance, 10 * delta)
	fps_label.text = "%d FPS (%.2f mspf)" % [Engine.get_frames_per_second(), 1000.0 / Engine.get_frames_per_second()]
	# Color FPS counter depending on framerate.
	# The Gradient resource is stored as metadata within the FPSLabel node (accessible in the inspector).
	fps_label.modulate = fps_label.get_meta("gradient").sample(remap(Engine.get_frames_per_second(), 0, 180, 0.0, 1.0))




func _on_previous_pressed() -> void:
	tester_index = max(0, tester_index - 1)
	update_gui()


func _on_next_pressed() -> void:
	tester_index = min(tester_index + 1, testers.get_child_count() - 1)
	update_gui()


func update_gui() -> void:
	$TestName.text = str(testers.get_child(tester_index).name).capitalize()
	$Previous.disabled = tester_index == 0
	$Next.disabled = tester_index == testers.get_child_count() - 1


func _on_msaa_item_selected(index: int) -> void:
	# Multi-sample anti-aliasing. High quality, but slow. It also does not smooth out the edges of
	# transparent (alpha scissor) textures.
	get_viewport().msaa_3d = index as Viewport.MSAA


func _on_limit_fps_scale_value_changed(value: float) -> void:
	# The rendering FPS affects the appearance of TAA, as higher framerates allow it to converge faster.
	# On high refresh rate monitors, TAA ghosting issues may appear less noticeable as a result
	# (if the GPU can keep up).
	$Antialiasing/LimitFPSContainer/Value.text = str(value)
	Engine.max_fps = roundi(value)


func _on_render_scale_value_changed(value: float) -> void:
	get_viewport().scaling_3d_scale = value
	$Antialiasing/RenderScaleContainer/Value.text = "%d%%" % (value * 100)
	# Update viewport resolution text.
	_on_viewport_size_changed()
	# FSR 1.0 is only effective if render scale is below 100%, so hide the setting if at native resolution or higher.
	$Antialiasing/FidelityFXFSR.visible = value < 1.0
	$Antialiasing/FSRSharpness.visible = get_viewport().scaling_3d_mode == Viewport.SCALING_3D_MODE_FSR and value < 1.0


func _on_amd_fidelityfx_fsr1_toggled(button_pressed: bool) -> void:
	get_viewport().scaling_3d_mode = Viewport.SCALING_3D_MODE_FSR if button_pressed else Viewport.SCALING_3D_MODE_BILINEAR
	# FSR 1.0 is only effective if render scale is below 100%, so hide the setting if at native resolution or higher.
	$Antialiasing/FSRSharpness.visible = button_pressed


func _on_fsr_sharpness_item_selected(index: int) -> void:
	# *Lower* values of FSR sharpness are sharper.
	match index:
		0:
			get_viewport().fsr_sharpness = 2.0
		1:
			get_viewport().fsr_sharpness = 0.8
		2:
			get_viewport().fsr_sharpness = 0.4
		3:
			get_viewport().fsr_sharpness = 0.2
		4:
			get_viewport().fsr_sharpness = 0.0


func _on_viewport_size_changed() -> void:
	$ViewportResolution.text = "Viewport resolution: %d×%d" % [
		get_viewport().size.x * get_viewport().scaling_3d_scale,
		get_viewport().size.y * get_viewport().scaling_3d_scale,
	]


func _on_v_sync_item_selected(index: int) -> void:
	# Vsync is enabled by default.
	# Vertical synchronization locks framerate and makes screen tearing not visible at the cost of
	# higher input latency and stuttering when the framerate target is not met.
	# Adaptive V-Sync automatically disables V-Sync when the framerate target is not met, and enables
	# V-Sync otherwise. This prevents suttering and reduces input latency when the framerate target
	# is not met, at the cost of visible tearing.
	if index == 0: # Disabled (default)
		DisplayServer.window_set_vsync_mode(DisplayServer.VSYNC_DISABLED)
	elif index == 1: # Adaptive
		DisplayServer.window_set_vsync_mode(DisplayServer.VSYNC_ADAPTIVE)
	elif index == 2: # Enabled
		DisplayServer.window_set_vsync_mode(DisplayServer.VSYNC_ENABLED)


func _on_taa_item_selected(index: int) -> void:
	# Temporal antialiasing. Smooths out everything including specular aliasing, but can introduce
	# ghosting artifacts and blurring in motion. Moderate performance cost.
	get_viewport().use_taa = index == 1


func _on_fxaa_item_selected(index: int) -> void:
	# Fast approximate anti-aliasing. Much faster than MSAA (and works on alpha scissor edges),
	# but blurs the whole scene rendering slightly.
	get_viewport().screen_space_aa = int(index == 1) as Viewport.ScreenSpaceAA
