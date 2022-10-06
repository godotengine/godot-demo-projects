extends Camera3D

const MOUSE_SENSITIVITY = 0.002
const MOVE_SPEED = 0.6

var rot = Vector3()
var velocity = Vector3()

@onready var label = $Label


func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	update_label()


func _process(delta):
	var motion = Vector3(
			Input.get_action_strength("move_right") - Input.get_action_strength("move_left"),
			0,
			Input.get_action_strength("move_back") - Input.get_action_strength("move_forward")
	)

	# Normalize motion to prevent diagonal movement from being
	# `sqrt(2)` times faster than straight movement.
	motion = motion.normalized()

	velocity += MOVE_SPEED * delta * (transform.basis * motion)
	velocity *= 0.85
	position += velocity


func _input(event):
	# Mouse look (only if the mouse is captured).
	if event is InputEventMouseMotion and Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED:
		# Horizontal mouse look.
		rot.y -= event.relative.x * MOUSE_SENSITIVITY
		# Vertical mouse look.
		rot.x = clamp(rot.x - event.relative.y * MOUSE_SENSITIVITY, -1.57, 1.57)
		transform.basis = Basis.from_euler(rot)

	if event.is_action_pressed("toggle_mouse_capture"):
		if Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED:
			Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
		else:
			Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

	if event.is_action_pressed("toggle_temporal_reprojection"):
		get_world_3d().environment.volumetric_fog_temporal_reprojection_enabled = not get_world_3d().environment.volumetric_fog_temporal_reprojection_enabled
		update_label()
	elif event.is_action_pressed("increase_temporal_reprojection"):
		get_world_3d().environment.volumetric_fog_temporal_reprojection_amount = clamp(get_world_3d().environment.volumetric_fog_temporal_reprojection_amount + 0.01, 0.5, 0.99)
		update_label()
	elif event.is_action_pressed("decrease_temporal_reprojection"):
		get_world_3d().environment.volumetric_fog_temporal_reprojection_amount = clamp(get_world_3d().environment.volumetric_fog_temporal_reprojection_amount - 0.01, 0.5, 0.99)
		update_label()
	elif event.is_action_pressed("increase_fog_density"):
		get_world_3d().environment.volumetric_fog_density = clamp(get_world_3d().environment.volumetric_fog_density + 0.01, 0.0, 1.0)
		update_label()
	elif event.is_action_pressed("decrease_fog_density"):
		get_world_3d().environment.volumetric_fog_density = clamp(get_world_3d().environment.volumetric_fog_density - 0.01, 0.0, 1.0)
		update_label()


func update_label():
	if get_world_3d().environment.volumetric_fog_temporal_reprojection_enabled:
		label.text = "Fog density: %.2f\nTemporal reprojection: Enabled\nTemporal reprojection strength: %.2f" % [get_world_3d().environment.volumetric_fog_density, get_world_3d().environment.volumetric_fog_temporal_reprojection_amount]
	else:
		label.text = "Fog density: %.2f\nTemporal reprojection: Disabled" % get_world_3d().environment.volumetric_fog_density
