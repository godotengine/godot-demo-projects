extends WorldEnvironment

const ROT_SPEED = 0.003
const ZOOM_SPEED = 0.125
const MAIN_BUTTONS = MOUSE_BUTTON_MASK_LEFT | MOUSE_BUTTON_MASK_RIGHT | MOUSE_BUTTON_MASK_MIDDLE

var tester_index := 0
var rot_x := deg_to_rad(-22.5)  # This must be kept in sync with RotationX.
var rot_y := deg_to_rad(90)  # This must be kept in sync with CameraHolder.
var zoom := 1.5

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

	if event.is_action_pressed(&"place_decal"):
		var origin := camera.global_position
		var target := camera.project_position(get_viewport().get_mouse_position(), 100)

		var query := PhysicsRayQueryParameters3D.create(origin, target)
		var result := camera.get_world_3d().direct_space_state.intersect_ray(query)

		if not result.is_empty():
			var decal := preload("res://decal.tscn").instantiate()
			add_child(decal)
			decal.get_node(^"Decal").modulate = Color(1.0,0.0,0)
			decal.position = result["position"]
			decal.transform.basis = camera.global_transform.basis

	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_WHEEL_UP:
			zoom -= ZOOM_SPEED
		if event.button_index == MOUSE_BUTTON_WHEEL_DOWN:
			zoom += ZOOM_SPEED
		zoom = clampf(zoom, 1.5, 4)

	if event is InputEventMouseMotion and event.button_mask & MAIN_BUTTONS:
		# Use `screen_relative` to make mouse sensitivity independent of viewport resolution.
		var relative_motion: Vector2 = event.screen_relative
		rot_y -= relative_motion.x * ROT_SPEED
		rot_x -= relative_motion.y * ROT_SPEED
		rot_x = clampf(rot_x, deg_to_rad(-90), 0)
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


func _on_decal_filter_mode_item_selected(index: int) -> void:
	# Indices in the OptionButton match RenderingServer decal filtering constants.
	RenderingServer.decals_set_filter(index)
