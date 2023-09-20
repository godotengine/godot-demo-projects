class_name GeneratedMesh extends MeshInstance3D

@export var use_terrain_types: bool = false

var perturb_func = null
var disable_all_perturb: bool = false
var surface_tool: SurfaceTool

var _verts_added: bool = false

func clear() -> void:
	self.mesh = ArrayMesh.new()

	self.surface_tool = SurfaceTool.new()
	self.surface_tool.begin(Mesh.PRIMITIVE_TRIANGLES)
	self.surface_tool.set_custom_format(0, SurfaceTool.CUSTOM_RGB_FLOAT)
	self.surface_tool.set_custom_format(1, SurfaceTool.CUSTOM_RGB_FLOAT)

	self._verts_added = false

func apply() -> Shape3D:
	if self._verts_added:
		self.surface_tool.generate_normals()
		self.surface_tool.generate_tangents()
	
	self.mesh = self.surface_tool.commit()
	return self.mesh.create_trimesh_shape()

func add_triangle_fan(
	v1: Vector3, v2: Vector3, v3: Vector3,
	c1: Color, c2: Color, c3: Color,
	types: Vector3,
	do_perturb: bool = true
) -> void:
	self._verts_added = true
	self.surface_tool.set_smooth_group(-1)
	var custom: Color = Color(types.x, types.y, types.z)

	self.surface_tool.set_color(c1)
	self.surface_tool.set_uv(Vector2(v1.x, v1.z))
	self.surface_tool.set_custom(0, Color(v1.x, v1.y, v1.z))
	if self.use_terrain_types:
		self.surface_tool.set_custom(1, custom)
	self.surface_tool.add_vertex(perturb_func.call(v1) if do_perturb and !disable_all_perturb and perturb_func else v1)

	self.surface_tool.set_color(c2)
	self.surface_tool.set_uv(Vector2(v2.x, v2.z))
	self.surface_tool.set_custom(0, Color(v2.x, v2.y, v2.z))
	if self.use_terrain_types:
		self.surface_tool.set_custom(1, custom)
	self.surface_tool.add_vertex(perturb_func.call(v2) if do_perturb and !disable_all_perturb and perturb_func else v2)

	self.surface_tool.set_color(c3)
	self.surface_tool.set_uv(Vector2(v3.x, v3.z))
	self.surface_tool.set_custom(0, Color(v3.x, v3.y, v3.z))
	if self.use_terrain_types:
		self.surface_tool.set_custom(1, custom)
	self.surface_tool.add_vertex(perturb_func.call(v3) if do_perturb and !disable_all_perturb and perturb_func else v3)

func add_quad(
	v1: Vector3, v2: Vector3, v3: Vector3, v4: Vector3,
	c1: Color, c2: Color, c3: Color, c4: Color,
	types: Vector3
) -> void:
	add_triangle_fan(v1, v3, v2, c1, c3, c2, types)
	add_triangle_fan(v2, v3, v4, c2, c3, c4, types)

func add_edge_fan(
	center: Vector3,
	edge: EdgeVertices,
	color: Color,
	type: float
) -> void:
	var types: Vector3 = Vector3(type, type, type)
	add_triangle_fan(center, edge.v1, edge.v2, color, color, color, types)
	add_triangle_fan(center, edge.v2, edge.v3, color, color, color, types)
	add_triangle_fan(center, edge.v3, edge.v4, color, color, color, types)
	add_triangle_fan(center, edge.v4, edge.v5, color, color, color, types)

func add_edge_strip(
	e1: EdgeVertices, e2: EdgeVertices,
	c1: Color, c2: Color,
	type1: float,
	type2: float
) -> void:
	var types: Vector3 = Vector3(type1, type2, type1)
	add_quad(e1.v1, e1.v2, e2.v1, e2.v2, c1, c1, c2, c2, types)
	add_quad(e1.v2, e1.v3, e2.v2, e2.v3, c1, c1, c2, c2, types)
	add_quad(e1.v3, e1.v4, e2.v3, e2.v4, c1, c1, c2, c2, types)
	add_quad(e1.v4, e1.v5, e2.v4, e2.v5, c1, c1, c2, c2, types)
