extends WorldEnvironment

const ROT_SPEED = 0.003
const ZOOM_SPEED = 0.125
const MAIN_BUTTONS = MOUSE_BUTTON_MASK_LEFT | MOUSE_BUTTON_MASK_RIGHT | MOUSE_BUTTON_MASK_MIDDLE

var tester_index := 0
var rot_x := deg_to_rad(-22.5)  # This must be kept in sync with RotationX.
var rot_y := deg_to_rad(90)  # This must be kept in sync with CameraHolder.
var zoom := 2.5
var base_height := int(ProjectSettings.get_setting("display/window/size/viewport_height"))

@onready var testers: Node3D = $Testers
@onready var camera_holder: Node3D = $CameraHolder  # Has a position and rotates on Y.
@onready var rotation_x: Node3D = $CameraHolder/RotationX
@onready var camera: Camera3D = $CameraHolder/RotationX/Camera3D


func _ready() -> void:
	camera_holder.transform.basis = Basis.from_euler(Vector3(0, rot_y, 0))
	rotation_x.transform.basis = Basis.from_euler(Vector3(rot_x, 0, 0))
	update_gui()


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed(&"ui_left"):
		_on_previous_pressed()
	if event.is_action_pressed(&"ui_right"):
		_on_next_pressed()

	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_WHEEL_UP:
			zoom -= ZOOM_SPEED
		if event.button_index == MOUSE_BUTTON_WHEEL_DOWN:
			zoom += ZOOM_SPEED
		zoom = clamp(zoom, 1.5, 4)

	if event is InputEventMouseMotion and event.button_mask & MAIN_BUTTONS:
		# Compensate motion speed to be resolution-independent (based on the window height).
		var relative_motion: Vector2 = event.relative * DisplayServer.window_get_size().y / base_height
		rot_y -= relative_motion.x * ROT_SPEED
		rot_x -= relative_motion.y * ROT_SPEED
		rot_x = clamp(rot_x, deg_to_rad(-90), 0)
		camera_holder.transform.basis = Basis.from_euler(Vector3(0, rot_y, 0))
		rotation_x.transform.basis = Basis.from_euler(Vector3(rot_x, 0, 0))


func _process(delta: float) -> void:
	var current_tester: Node3D = testers.get_child(tester_index)
	# This code assumes CameraHolder's X and Y coordinates are already correct.
	var current_position := camera_holder.global_transform.origin.z
	var target_position := current_tester.global_transform.origin.z
	camera_holder.global_transform.origin.z = lerpf(current_position, target_position, 3 * delta)
	camera.position.z = lerpf(camera.position.z, zoom, 10 * delta)


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


func _on_enable_sun_toggled(button_pressed: bool) -> void:
	$DirectionalLight3D.visible = button_pressed


func _on_animate_lights_toggled(button_pressed: bool) -> void:
	for animatable_node in get_tree().get_nodes_in_group("animatable"):
		animatable_node.set_process(button_pressed)


func _on_shadow_resolution_item_selected(index: int) -> void:
	var size := 4096
	match index:
		0:
			size = 1024
		1:
			size = 2048
		2:
			size = 4096
		3:
			size = 8192
		4:
			size = 16384

	RenderingServer.directional_shadow_atlas_set_size(size, true)
	get_viewport().positional_shadow_atlas_size = size


func _on_shadow_filter_quality_item_selected(index: int) -> void:
	# Values are numbered in the OptionButton to match the RenderingServer.ShadowQuality enum.
	RenderingServer.directional_soft_shadow_filter_set_quality(index)
	RenderingServer.positional_soft_shadow_filter_set_quality(index)


func _on_projector_filter_mode_item_selected(index: int) -> void:
	# Values are numbered in the OptionButton to match the RenderingServer.LightProjectorFilter enum.
	RenderingServer.light_projectors_set_filter(index)
