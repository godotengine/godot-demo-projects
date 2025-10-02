class_name Line3D
extends MeshInstance3D


func _ready() -> void:
	mesh = ImmediateMesh.new()
	var material := StandardMaterial3D.new()
	material.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	set_material_override(material)


func draw_path(path: PackedVector3Array) -> void:
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
