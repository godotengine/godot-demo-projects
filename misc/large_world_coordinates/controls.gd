extends VBoxContainer

const ROT_SPEED = 0.003
const ZOOM_SPEED = 0.5
const MAIN_BUTTONS = MOUSE_BUTTON_MASK_LEFT | MOUSE_BUTTON_MASK_MIDDLE | MOUSE_BUTTON_MASK_RIGHT

@export var camera: Camera3D
@export var camera_holder: Node3D
@export var rotation_x: Node3D
@export var node_to_move: Node3D
@export var rigid_body: RigidBody3D

@onready var zoom := camera.position.z
var base_height: int = ProjectSettings.get_setting("display/window/size/viewport_height")

@onready var rot_x := rotation_x.rotation.x
@onready var rot_y := camera_holder.rotation.y

func _ready() -> void:
	if OS.has_feature("double"):
		%HelpLabel.text = "Double precision is enabled in this engine build.\nNo shaking should occur at high coordinate levels\n(±65,536 or more on any axis)."
		%HelpLabel.add_theme_color_override("font_color", Color(0.667, 1, 0.667))


func _process(delta: float) -> void:
	%Coordinates.text = "X: [color=#fb9]%f[/color]\nY: [color=#bfa]%f[/color]\nZ: [color=#9cf]%f[/color]" % [node_to_move.position.x, node_to_move.position.y, node_to_move.position.z]
	if %IncrementX.button_pressed:
		node_to_move.position.x += 10_000 * delta
	if %IncrementY.button_pressed:
		node_to_move.position.y += 100_000 * delta
	if %IncrementZ.button_pressed:
		node_to_move.position.z += 1_000_000 * delta


func _input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_WHEEL_UP:
			zoom -= ZOOM_SPEED
		if event.button_index == MOUSE_BUTTON_WHEEL_DOWN:
			zoom += ZOOM_SPEED
		zoom = clampf(zoom, 4, 15)
		camera.position.z = zoom

	if event is InputEventMouseMotion and event.button_mask & MAIN_BUTTONS:
		# Compensate motion speed to be resolution-independent (based on the window height).
		var relative_motion: Vector2 = event.relative * DisplayServer.window_get_size().y / base_height
		rot_y -= relative_motion.x * ROT_SPEED
		rot_x -= relative_motion.y * ROT_SPEED
		rot_x = clampf(rot_x, -1.4, 0.16)
		camera_holder.transform.basis = Basis.from_euler(Vector3(0, rot_y, 0))
		rotation_x.transform.basis = Basis.from_euler(Vector3(rot_x, 0, 0))


func _on_go_to_button_pressed(x_position: int) -> void:
	if x_position == 0:
		# Reset all coordinates, not just X.
		node_to_move.position = Vector3.ZERO
	else:
		node_to_move.position.x = x_position


func _on_open_documentation_pressed() -> void:
	OS.shell_open("https://docs.godotengine.org/en/latest/tutorials/physics/large_world_coordinates.html")
