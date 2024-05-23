extends Node

const ROT_SPEED = 0.003
const ZOOM_SPEED = 0.125
const MAIN_BUTTONS = MOUSE_BUTTON_MASK_LEFT | MOUSE_BUTTON_MASK_RIGHT | MOUSE_BUTTON_MASK_MIDDLE

var tester_index := 0
var rot_x := -TAU / 16  # This must be kept in sync with RotationX.
var rot_y := TAU / 8  # This must be kept in sync with CameraHolder.
var camera_distance := 2.0
var base_height: = int(ProjectSettings.get_setting("display/window/size/viewport_height"))

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

	# Only display player name field if relevant.
	$Testers/Label3DHealthBar/Name2.visible = str(testers.get_child(tester_index).name) == "Label3DHealthBar"
	$Testers/Label3DHealthBar/LineEdit.visible = str(testers.get_child(tester_index).name) == "Label3DHealthBar"


func _on_line_edit_text_submitted(_new_text: String) -> void:
	$Testers/Label3DHealthBar/LineEdit.release_focus()
