extends Node3D


func _input(event):
	if event.is_action_pressed("toggle_occlusion_culling"):
		get_viewport().use_occlusion_culling = not get_viewport().use_occlusion_culling
		update_labels()
	if event.is_action_pressed("toggle_mesh_lod"):
		get_viewport().mesh_lod_threshold = 1.0 if is_zero_approx(get_viewport().mesh_lod_threshold) else 0.0
		update_labels()
	if event.is_action_pressed("cycle_draw_mode"):
		get_viewport().debug_draw = wrapi(get_viewport().debug_draw + 1, 0, 5)
		update_labels()


func _process(delta):
	$Performance.text = """%d FPS (%.2f mspf)

Currently rendering:
%d objects
%dK primitive indices
%d draw calls
""" % [
	Engine.get_frames_per_second(),
	1000.0 / Engine.get_frames_per_second(),
	RenderingServer.get_rendering_info(RenderingServer.RENDERING_INFO_TOTAL_OBJECTS_IN_FRAME),
	RenderingServer.get_rendering_info(RenderingServer.RENDERING_INFO_TOTAL_PRIMITIVES_IN_FRAME) * 0.001,
	RenderingServer.get_rendering_info(RenderingServer.RENDERING_INFO_TOTAL_DRAW_CALLS_IN_FRAME),
]


func update_labels():
	$OcclusionCulling.text = "Occlusion culling: %s" % ("Enabled" if get_viewport().use_occlusion_culling else "Disabled")
	$MeshLOD.text = "Mesh LOD: %s" % ("Enabled" if not is_zero_approx(get_viewport().mesh_lod_threshold) else "Disabled")
	$DrawMode.text = "Draw mode: %s" % get_draw_mode_string(get_viewport().debug_draw)


func get_draw_mode_string(draw_mode):
	match draw_mode:
		0:
			return "Normal"
		1:
			return "Unshaded"
		2:
			return "Lighting"
		3:
			return "Overdraw"
		4:
			return "Wireframe"
