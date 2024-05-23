extends Camera3D

const MOUSE_SENSITIVITY = 0.002
const MOVE_SPEED = 0.6

var volumetric_fog_volume_size := int(ProjectSettings.get_setting("rendering/environment/volumetric_fog/volume_size"))
var volumetric_fog_volume_depth := int(ProjectSettings.get_setting("rendering/environment/volumetric_fog/volume_depth"))

var rot := Vector3()
var velocity := Vector3()

@onready var label: Label = $Label

func _ready() -> void:
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	update_label()


func _process(delta: float) -> void:
	var motion := Vector3(
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


func _input(event: InputEvent) -> void:
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
	elif event.is_action_pressed("increase_volumetric_fog_quality"):
		volumetric_fog_volume_size = clamp(volumetric_fog_volume_size + 16, 16, 384)
		volumetric_fog_volume_depth = clamp(volumetric_fog_volume_depth + 16, 16, 384)
		RenderingServer.environment_set_volumetric_fog_volume_size(volumetric_fog_volume_size, volumetric_fog_volume_depth)
		update_label()
	elif event.is_action_pressed("decrease_volumetric_fog_quality"):
		volumetric_fog_volume_size = clamp(volumetric_fog_volume_size - 16, 16, 384)
		volumetric_fog_volume_depth = clamp(volumetric_fog_volume_depth - 16, 16, 384)
		RenderingServer.environment_set_volumetric_fog_volume_size(volumetric_fog_volume_size, volumetric_fog_volume_depth)
		update_label()


func update_label() -> void:
	if get_world_3d().environment.volumetric_fog_temporal_reprojection_enabled:
		label.text = "Fog density: %.2f\nTemporal reprojection: Enabled\nTemporal reprojection strength: %.2f\nVolumetric fog quality: %d×%d×%d" % [
			get_world_3d().environment.volumetric_fog_density,
			get_world_3d().environment.volumetric_fog_temporal_reprojection_amount,
			volumetric_fog_volume_size,
			volumetric_fog_volume_size,
			volumetric_fog_volume_depth,
		]
	else:
		label.text = "Fog density: %.2f\nTemporal reprojection: Disabled\nVolumetric fog quality: %d×%d×%d" % [
			get_world_3d().environment.volumetric_fog_density,
			volumetric_fog_volume_size,
			volumetric_fog_volume_size,
			volumetric_fog_volume_depth,
		]
