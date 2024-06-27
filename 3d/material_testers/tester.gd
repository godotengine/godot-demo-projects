extends Node3D

const INTERP_SPEED = 2
const ROT_SPEED = 0.003
const ZOOM_SPEED = 0.1
const ZOOM_MAX = 2.5
const MAIN_BUTTONS = MOUSE_BUTTON_MASK_LEFT | MOUSE_BUTTON_MASK_MIDDLE | MOUSE_BUTTON_MASK_RIGHT

var tester_index := 0
var rot_x := -0.5  # This must be kept in sync with RotationX.
var rot_y := -0.5  # This must be kept in sync with CameraHolder.
var zoom := 5.0
var base_height := int(ProjectSettings.get_setting("display/window/size/viewport_height"))

var backgrounds: Array[Dictionary] = [
	{ path = "res://backgrounds/schelde.hdr", name = "Riverside" },
	{ path = "res://backgrounds/lobby.hdr", name = "Lobby" },
	{ path = "res://backgrounds/park.hdr", name = "Park" },
	{ path = "res://backgrounds/night.hdr", name = "Night" },
	{ path = "res://backgrounds/experiment.hdr", name = "Experiment" },
]

@onready var testers: Node3D = $Testers
@onready var material_name: Label = $UI/MaterialName

@onready var camera_holder: Node3D = $CameraHolder  # Has a position and rotates on Y.
@onready var rotation_x: Node3D = $CameraHolder/RotationX
@onready var camera: Camera3D = $CameraHolder/RotationX/Camera

func _ready() -> void:
	for background in backgrounds:
		get_node(^"UI/Background").add_item(background.name)

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
		zoom = clamp(zoom, 2, 8)
		camera.position.z = zoom

	if event is InputEventMouseMotion and event.button_mask & MAIN_BUTTONS:
		# Compensate motion speed to be resolution-independent (based on the window height).
		var relative_motion: Vector2 = event.relative * DisplayServer.window_get_size().y / base_height
		rot_y -= relative_motion.x * ROT_SPEED
		rot_y = clamp(rot_y, -1.95, 1.95)
		rot_x -= relative_motion.y * ROT_SPEED
		rot_x = clamp(rot_x, -1.4, 0.45)
		camera_holder.transform.basis = Basis.from_euler(Vector3(0, rot_y, 0))
		rotation_x.transform.basis = Basis.from_euler(Vector3(rot_x, 0, 0))


func _process(delta: float) -> void:
	var current_tester: Node3D = testers.get_child(tester_index)
	# This code assumes CameraHolder's Y and Z coordinates are already correct.
	var target_position := current_tester.transform.origin.x
	var current_position := camera_holder.transform.origin.x
	camera_holder.transform.origin.x = lerp(current_position, target_position, INTERP_SPEED * delta)


func _on_previous_pressed() -> void:
	if tester_index > 0:
		tester_index -= 1

	update_gui()


func _on_next_pressed() -> void:
	if tester_index < testers.get_child_count() - 1:
		tester_index += 1

	update_gui()


func update_gui() -> void:
	var current_tester := testers.get_child(tester_index)
	material_name.text = current_tester.get_name()
	$UI/Previous.disabled = tester_index == 0
	$UI/Next.disabled = tester_index == testers.get_child_count() - 1


func _on_bg_item_selected(index: int) -> void:
	var sky_material: PanoramaSkyMaterial = $WorldEnvironment.environment.sky.sky_material

	sky_material.panorama = load(backgrounds[index].path)

	# Force reflection probes to update by moving them slightly.
	for reflection_probe: ReflectionProbe in get_tree().get_nodes_in_group(&"reflection_probe"):
		reflection_probe.position.y += randf_range(-0.0001, 0.0001)


func _on_reflection_probes_item_selected(index: int) -> void:
	match index:
		0:  # No Reflection Probes
			for reflection_probe: ReflectionProbe in get_tree().get_nodes_in_group(&"reflection_probe"):
				reflection_probe.visible = false

		1:  # Reflection Probes (Reflection only)
			for reflection_probe: ReflectionProbe in get_tree().get_nodes_in_group(&"reflection_probe"):
				reflection_probe.visible = true
				reflection_probe.ambient_mode = ReflectionProbe.AMBIENT_DISABLED

		2:  # Reflection Probes (Reflection + Ambient)
			for reflection_probe: ReflectionProbe in get_tree().get_nodes_in_group(&"reflection_probe"):
				reflection_probe.visible = true
				reflection_probe.ambient_mode = ReflectionProbe.AMBIENT_ENVIRONMENT


func _on_quit_pressed() -> void:
	get_tree().quit()
