extends Node3D

func _ready():
	# Clear the viewport.
	var viewport = $SubViewport
	$SubViewport.set_clear_mode(SubViewport.CLEAR_MODE_ONLY_NEXT_FRAME)

	# Let two frames pass to make sure the vieport is captured.
	await get_tree().process_frame
	await get_tree().process_frame

	# Retrieve the texture and set it to the viewport quad.
	$ViewportQuad.material_override.albedo_texture = viewport.get_texture()
