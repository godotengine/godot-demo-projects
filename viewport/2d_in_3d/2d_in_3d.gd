extends Node3D

func _ready():
	# Clear the viewport.
	var viewport = $SubViewport
	$SubViewport.set_clear_mode(SubViewport.CLEAR_MODE_ONCE)

	# Retrieve the texture and set it to the viewport quad.
	$ViewportQuad.material_override.albedo_texture = viewport.get_texture()
