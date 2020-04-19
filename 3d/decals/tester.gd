extends WorldEnvironment

const ROT_SPEED = 0.003
const ZOOM_SPEED = 0.125
const MAIN_BUTTONS = MOUSE_BUTTON_MASK_LEFT | MOUSE_BUTTON_MASK_RIGHT | MOUSE_BUTTON_MASK_MIDDLE

var tester_index = 0
var rot_x = deg_to_rad(-22.5)  # This must be kept in sync with RotationX.
var rot_y = deg_to_rad(90)  # This must be kept in sync with CameraHolder.
var zoom = 1.5
var base_height = ProjectSettings.get_setting("display/window/size/viewport_height")

@onready var testers = $Testers
@onready var camera_holder = $CameraHolder # Has a position and rotates on Y.
@onready var rotation_x = $CameraHolder/RotationX
@onready var camera = $CameraHolder/RotationX/Camera3D
@onready var place_decal_raycast = $CameraHolder/RotationX/Camera3D/PlaceDecalRayCast

func _ready():
	camera_holder.transform.basis = Basis.from_euler(Vector3(0, rot_y, 0))
	rotation_x.transform.basis = Basis.from_euler(Vector3(rot_x, 0, 0))
	update_gui()


func _unhandled_input(event):
	if event.is_action_pressed("ui_left"):
		_on_previous_pressed()
	if event.is_action_pressed("ui_right"):
		_on_next_pressed()

	if event.is_action_pressed("place_decal"):
		place_decal_raycast.target_position = camera.project_position(get_viewport().get_mouse_position(), 100)
		place_decal_raycast.force_raycast_update()

		var decal = preload("res://decal.tscn").instantiate()
		add_child(decal)
		decal.position = place_decal_raycast.get_collision_point()

	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_WHEEL_UP:
			zoom -= ZOOM_SPEED
		if event.button_index == MOUSE_BUTTON_WHEEL_DOWN:
			zoom += ZOOM_SPEED
		zoom = clamp(zoom, 1.5, 4)

	if event is InputEventMouseMotion and event.button_mask & MAIN_BUTTONS:
		# Compensate motion speed to be resolution-independent (based on the window height).
		var relative_motion = event.relative * DisplayServer.window_get_size().y / base_height
		rot_y -= relative_motion.x * ROT_SPEED
		rot_x -= relative_motion.y * ROT_SPEED
		rot_x = clamp(rot_x, deg_to_rad(-90), 0)
		camera_holder.transform.basis = Basis.from_euler(Vector3(0, rot_y, 0))
		rotation_x.transform.basis = Basis.from_euler(Vector3(rot_x, 0, 0))


func _process(delta):
	var current_tester = testers.get_child(tester_index)
	# This code assumes CameraHolder's X and Y coordinates are already correct.
	var current_position = camera_holder.global_transform.origin.z
	var target_position = current_tester.global_transform.origin.z
	camera_holder.global_transform.origin.z = lerp(current_position, target_position, 3 * delta)
	camera.position.z = lerp(camera.position.z, zoom, 10 * delta)


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


func _on_decal_filter_mode_item_selected(index):
	# Indices in the OptionButton match RenderingServer decal filtering constants.
	RenderingServer.decals_set_filter(index)
