extends Spatial

const INTERP_SPEED = 2
const ROT_SPEED = 0.003
const ZOOM_SPEED = 0.1
const ZOOM_MAX = 2.5
const MAIN_BUTTONS = BUTTON_MASK_LEFT | BUTTON_MASK_RIGHT | BUTTON_MASK_MIDDLE

var tester_index = 0
var rot_x = -0.5 # This must be kept in sync with RotationX.
var rot_y = -0.5 # This must be kept in sync with CameraHolder.
var zoom = 5
var base_height = ProjectSettings.get_setting("display/window/size/height")

var backgrounds = [
	{ path = "res://backgrounds/schelde.hdr", name = "Riverside"},
	{ path = "res://backgrounds/lobby.hdr", name = "Lobby"},
	{ path = "res://backgrounds/park.hdr", name = "Park"},
	{ path = "res://backgrounds/night.hdr", name = "Night"},
	{ path = "res://backgrounds/experiment.hdr", name = "Experiment"},
]

onready var testers = $Testers
onready var material_name = $UI/MaterialName

onready var camera_holder = $CameraHolder # Has a position and rotates on Y.
onready var rotation_x = $CameraHolder/RotationX
onready var camera = $CameraHolder/RotationX/Camera

func _ready():
	for background in backgrounds:
		get_node("UI/Background").add_item(background.name)


func _unhandled_input(ev):
	if ev is InputEventMouseButton:
		if ev.button_index == BUTTON_WHEEL_UP:
			zoom -= ZOOM_SPEED
		if ev.button_index == BUTTON_WHEEL_DOWN:
			zoom += ZOOM_SPEED
		zoom = clamp(zoom, 2, 8)
		camera.translation.z = zoom

	if ev is InputEventMouseMotion and ev.button_mask & MAIN_BUTTONS:
		# Compensate motion speed to be resolution-independent (based on the window height).
		var relative_motion = ev.relative * get_viewport().size.y / base_height
		rot_y -= relative_motion.x * ROT_SPEED
		rot_x -= relative_motion.y * ROT_SPEED
		rot_y = clamp(rot_y, -1.6, 1.6)
		rot_x = clamp(rot_x, -1.4, 0.5)
		camera_holder.transform.basis = Basis(Vector3(0, rot_y, 0))
		rotation_x.transform.basis = Basis(Vector3(rot_x, 0, 0))


func _process(delta):
	var current_tester = testers.get_child(tester_index)
	material_name.text = current_tester.get_name()
	# This code assumes CameraHolder's Y and Z coordinates are already correct.
	var target_position = current_tester.transform.origin.x
	var current_position = camera_holder.transform.origin.x
	camera_holder.transform.origin.x = lerp(current_position, target_position, INTERP_SPEED * delta)


func _on_Previous_pressed():
	if tester_index > 0:
		tester_index -= 1


func _on_Next_pressed():
	if tester_index < testers.get_child_count() -1:
		tester_index += 1


func _on_bg_item_selected(index):
	get_node("WorldEnvironment").environment.background_sky.panorama = load(backgrounds[index].path)
