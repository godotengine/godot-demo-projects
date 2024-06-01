extends Node3D

## Camera idle scale effect intensity.
const CAMERA_IDLE_SCALE = 0.005

var counter := 0.0
@onready var camera_base_rotation: Vector3 = $Camera3D.rotation

func _ready() -> void:
	# Clear the viewport.
	var viewport: SubViewport = $SubViewport
	viewport.render_target_clear_mode = SubViewport.CLEAR_MODE_ONCE

	# Retrieve the texture and set it to the viewport quad.
	$ViewportQuad.material_override.albedo_texture = viewport.get_texture()


func _process(delta: float) -> void:
	# Animate the camera with an "idle" animation.
	counter += delta
	$Camera3D.rotation.x = camera_base_rotation.y + cos(counter) * CAMERA_IDLE_SCALE
	$Camera3D.rotation.y = camera_base_rotation.y + sin(counter) * CAMERA_IDLE_SCALE
	$Camera3D.rotation.z = camera_base_rotation.y + sin(counter) * CAMERA_IDLE_SCALE
