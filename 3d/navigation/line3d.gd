extends MeshInstance3D


func _ready():
	set_mesh(ImmediateMesh.new())
	var material := StandardMaterial3D.new()
	material.flags_unshaded = true
	material.albedo_color = Color.WHITE
	set_material_override(material)


func draw_path(path):
	var im: ImmediateMesh = mesh
	im.clear_surfaces()
	im.surface_begin(Mesh.PRIMITIVE_POINTS, null)
	im.surface_add_vertex(path[0])
	im.surface_add_vertex(path[path.size() - 1])
	im.surface_end()
	im.surface_begin(Mesh.PRIMITIVE_LINE_STRIP, null)
	for current_vector in path:
		im.surface_add_vertex(current_vector)
	im.surface_end()
