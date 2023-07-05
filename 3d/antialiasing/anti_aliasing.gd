extends Node

const ROT_SPEED = 0.003
const ZOOM_SPEED = 0.125
const MAIN_BUTTONS = MOUSE_BUTTON_MASK_LEFT | MOUSE_BUTTON_MASK_RIGHT | MOUSE_BUTTON_MASK_MIDDLE

var tester_index = 0
var rot_x = -TAU / 16  # This must be kept in sync with RotationX.
var rot_y = TAU / 8  # This must be kept in sync with CameraHolder.
var camera_distance = 2.0
var base_height = ProjectSettings.get_setting("display/window/size/viewport_height")

@onready var testers = $Testers
@onready var camera_holder = $CameraHolder # Has a position and rotates on Y.
@onready var rotation_x = $CameraHolder/RotationX
@onready var camera = $CameraHolder/RotationX/Camera3D

func _ready():
	camera_holder.transform.basis = Basis.from_euler(Vector3(0, rot_y, 0))
	rotation_x.transform.basis = Basis.from_euler(Vector3(rot_x, 0, 0))
	update_gui()
	get_viewport().size_changed.connect(_on_viewport_size_changed)


func _unhandled_input(event):
	if event.is_action_pressed("ui_left"):
		_on_previous_pressed()
	if event.is_action_pressed("ui_right"):
		_on_next_pressed()

	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_WHEEL_UP:
			camera_distance -= ZOOM_SPEED
		if event.button_index == MOUSE_BUTTON_WHEEL_DOWN:
			camera_distance += ZOOM_SPEED
		camera_distance = clamp(camera_distance, 1.5, 6)

	if event is InputEventMouseMotion and event.button_mask & MAIN_BUTTONS:
		# Compensate motion speed to be resolution-independent (based on the window height).
		var relative_motion = event.relative * DisplayServer.window_get_size().y / base_height
		rot_y -= relative_motion.x * ROT_SPEED
		rot_x -= relative_motion.y * ROT_SPEED
		rot_x = clamp(rot_x, -1.57, 0)
		camera_holder.transform.basis = Basis.from_euler(Vector3(0, rot_y, 0))
		rotation_x.transform.basis = Basis.from_euler(Vector3(rot_x, 0, 0))


func _process(delta):
	var current_tester = testers.get_child(tester_index)
	# This code assumes CameraHolder's X and Y coordinates are already correct.
	var current_position = camera_holder.global_transform.origin.z
	var target_position = current_tester.global_transform.origin.z
	camera_holder.global_transform.origin.z = lerpf(current_position, target_position, 3 * delta)
	camera.position.z = lerpf(camera.position.z, camera_distance, 10 * delta)


func _on_previous_pressed():
	tester_index = max(0, tester_index - 1)
	update_gui()


func _on_next_pressed():
	tester_index = min(tester_index + 1, testers.get_child_count() - 1)
	update_gui()


func update_gui():
	$TestName.text = str(testers.get_child(tester_index).name).capitalize()
	$Previous.disabled = tester_index == 0
	$Next.disabled = tester_index == testers.get_child_count() - 1


func _on_fxaa_toggled(button_pressed):
	get_viewport().screen_space_aa = Viewport.SCREEN_SPACE_AA_FXAA if button_pressed else Viewport.SCREEN_SPACE_AA_DISABLED


func _on_temporal_antialiasing_toggled(button_pressed):
	get_viewport().use_taa = button_pressed
	$FPSLimit.visible = button_pressed

func _on_fps_limit_item_selected(index):
	# The rendering FPS affects the appearance of TAA, as higher framerates allow it to converge faster.
	# On high refresh rate monitors, TAA ghosting issues may appear less noticeable as a result
	# (if the GPU can keep up).
	match index:
		0:
			Engine.max_fps = 30
		1:
			Engine.max_fps = 60
		2:
			# No limit, other than what's enforced by V-Sync.
			Engine.max_fps = 0


func _on_msaa_item_selected(index):
	get_viewport().msaa_3d = index


func _on_render_scale_value_changed(value):
	get_viewport().scaling_3d_scale = value
	$Antialiasing/HBoxContainer/Value.text = "%d%%" % (value * 100)
	# Update viewport resolution text.
	_on_viewport_size_changed()
	# FSR 1.0 is only effective if render scale is below 100%, so hide the setting if at native resolution or higher.
	$Antialiasing/FidelityFXFSR.visible = value < 1.0
	$Antialiasing/FSRSharpness.visible = get_viewport().scaling_3d_mode == Viewport.SCALING_3D_MODE_FSR and value < 1.0


func _on_amd_fidelityfx_fsr1_toggled(button_pressed):
	get_viewport().scaling_3d_mode = Viewport.SCALING_3D_MODE_FSR if button_pressed else Viewport.SCALING_3D_MODE_BILINEAR
	# FSR 1.0 is only effective if render scale is below 100%, so hide the setting if at native resolution or higher.
	$Antialiasing/FSRSharpness.visible = button_pressed


func _on_fsr_sharpness_item_selected(index):
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


func _on_viewport_size_changed():
	$ViewportResolution.text = "Viewport resolution: %d×%d" % [get_viewport().size.x * get_viewport().scaling_3d_scale, get_viewport().size.y * get_viewport().scaling_3d_scale]
