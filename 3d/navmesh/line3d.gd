extends ImmediateGeometry


var _material := SpatialMaterial.new()


func _ready():
	_material.flags_unshaded = true
	_material.flags_use_point_size = true
	_material.albedo_color = Color.white


func draw_path(path):
	set_material_override(_material)
	clear()
	begin(Mesh.PRIMITIVE_POINTS, null)
	add_vertex(path[0])
	add_vertex(path[path.size() - 1])
	end()
	begin(Mesh.PRIMITIVE_LINE_STRIP, null)
	for x in path:
		add_vertex(x)
	end()
