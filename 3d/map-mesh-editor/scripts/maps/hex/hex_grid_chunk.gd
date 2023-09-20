class_name HexGridChunk extends StaticBody3D

const splat_color_1: Color = Color(1, 0, 0)
const splat_color_2: Color = Color(0, 1, 0)
const splat_color_3: Color = Color(0, 0, 1)

@onready var terrain: GeneratedMesh = $HexMeshTerrain
@onready var water: GeneratedMesh = $HexMeshWater
@onready var features: HexFeatureManager = $HexFeatureManager

var chunk_id: int = -1
var texture_arr: Texture2DArray
var shape_owner_id: int
var shape: Shape3D
var cells: Array[HexCell] = []
var dirty: bool = false

signal chunk_pressed(pos: Vector3)

func _ready() -> void:
	self.terrain.perturb_func = func(v): return HexMetrics.perturb(v)
	self.water.perturb_func = func(v): return HexMetrics.perturb(v)
	
	self.shape_owner_id = create_shape_owner(self)
	self.cells.clear()
	self.cells.resize(HexMetrics.CHUNK_SIZE_X * HexMetrics.CHUNK_SIZE_Z)
	var terrain_mat = self.terrain.get_active_material(0)
	if terrain_mat is ShaderMaterial:
		terrain_mat.set_shader_parameter("texture_albedo", texture_arr)

func _input_event(_camera, event, pos, _normal, _shape_idx):
	if event.is_action_pressed("select"):
		emit_signal("chunk_pressed", pos)

func _process(_delta):
	if self.dirty:
		self.dirty = false
		_rebuild_mesh()

func refresh() -> void:
	self.dirty = true

func _rebuild_mesh() -> void:
	self.terrain.clear()
	self.water.clear()
	self.features.clear()
	
	for c in range(self.cells.size()):
		add_cell_mesh(self.cells[c])
	
	self.shape = self.terrain.apply()
	shape_owner_add_shape(self.shape_owner_id, self.shape)
	
	self.water.apply()
	self.features.apply()

func add_cell(i: int, cell: HexCell):
	self.cells[i] = cell
	cell.connect("changed", _cell_changed)
	cell.chunk_id = self.chunk_id
	add_child(cell)

func _cell_changed():
	refresh()

func add_cell_mesh(cell: HexCell):
	if !cell.is_under_water():
		self.features.add_feature(cell, cell.position)
	for i in 6:
		add_hexagon_segment(cell, i)

func add_hexagon_segment(cell: HexCell, direction: int):
	var center: Vector3 = cell.position
	var e: EdgeVertices = EdgeVertices.new(center + HexMetrics.get_first_solid_corner(direction), center + HexMetrics.get_second_solid_corner(direction))
	
	self.terrain.add_edge_fan(center, e, splat_color_1, cell.terrain)
	
	if direction <= Hex.Direction.SE:
		add_connection(cell, direction, e)
	
	if cell.is_under_water():
		add_water(direction, cell, center)
	
	if !cell.is_under_water():
		features.add_feature(cell, (center + e.v1 + e.v5) * (1.0 / 3.0))

func add_connection(cell: HexCell, dir: int, e1: EdgeVertices):
	var neighbor: HexCell = cell.get_neighbor(dir, null)
	if !neighbor:
		return
	
	# Calculate bridge
	var bridge: Vector3 = HexMetrics.get_bridge(dir)
	bridge.y = neighbor.position.y - cell.position.y
	
	var e2: EdgeVertices = EdgeVertices.new(e1.v1 + bridge, e1.v5 + bridge)
	
	if cell.get_edge_type(dir) == Hex.EdgeType.Slope:
		add_edge_terraces(e1, e2, cell, neighbor)
	else:
		self.terrain.add_edge_strip(e1, e2, splat_color_1, splat_color_2, cell.terrain, neighbor.terrain)
	
	# Calculate corners
	if dir <= Hex.Direction.E:
		var next_neighbor: HexCell = cell.get_neighbor(Hex.next_dir(dir), null)
		if next_neighbor:
			var v5: Vector3 = e1.v5 + HexMetrics.get_bridge(Hex.next_dir(dir))
			v5.y = next_neighbor.position.y
			
			if cell.elevation <= neighbor.elevation:
				if cell.elevation <= next_neighbor.elevation:
					add_corner(e1.v5, e2.v5, v5, cell, neighbor, next_neighbor)
				else:
					add_corner(v5, e1.v5, e2.v5, next_neighbor, cell, neighbor)
			elif neighbor.elevation <= next_neighbor.elevation:
				add_corner(e2.v5, v5, e1.v5, neighbor, next_neighbor, cell)
			else:
				add_corner(v5, e1.v5, e2.v5, next_neighbor, cell, neighbor)

func add_edge_terraces(begin: EdgeVertices, end: EdgeVertices, begin_cell: HexCell, end_cell: HexCell):
	var e2: EdgeVertices = begin.terrace_lerp(end, 1)
	var c2: Color = HexMetrics.terrace_lerp_color(splat_color_1, splat_color_2, 1)
	var t1: float = begin_cell.terrain
	var t2: float = end_cell.terrain
	
	self.terrain.add_edge_strip(begin, e2, splat_color_1, c2, t1, t2)
	
	for i in range(2, HexMetrics.TERRACE_STEPS):
		var e1: EdgeVertices = e2
		var c1: Color = c2
		e2 = begin.terrace_lerp(end, i)
		c2 = HexMetrics.terrace_lerp_color(splat_color_1, splat_color_2, i)
		self.terrain.add_edge_strip(e1, e2, c1, c2, t1, t2)
	
	self.terrain.add_edge_strip(e2, end, c2, splat_color_2, t1, t2)

func add_corner(bottom: Vector3, left: Vector3, right: Vector3, bottom_cell: HexCell, left_cell: HexCell, right_cell: HexCell):
	var left_edge_type: Hex.EdgeType = bottom_cell.get_edge_type_from_cell(left_cell)
	var right_edge_type: Hex.EdgeType = bottom_cell.get_edge_type_from_cell(right_cell)
	
	if left_edge_type == Hex.EdgeType.Slope:
		if right_edge_type == Hex.EdgeType.Slope:
			add_corner_terraces(bottom, left, right, bottom_cell, left_cell, right_cell)
		elif right_edge_type == Hex.EdgeType.Flat:
			add_corner_terraces(left, right, bottom, left_cell, right_cell, bottom_cell)
		else:
			add_corner_terraces_cliff(bottom, left, right, bottom_cell, left_cell, right_cell)
	elif right_edge_type == Hex.EdgeType.Slope:
		if left_edge_type == Hex.EdgeType.Flat:
			add_corner_terraces(right, bottom, left, right_cell, bottom_cell, left_cell)
		else:
			add_corner_cliff_terraces(bottom, left, right, bottom_cell, left_cell, right_cell)
	elif left_cell.get_edge_type_from_cell(right_cell) == Hex.EdgeType.Slope:
		if left_cell.elevation < right_cell.elevation:
			add_corner_cliff_terraces(right, bottom, left, right_cell, bottom_cell, left_cell)
		else:
			add_corner_terraces_cliff(left, right, bottom, left_cell, right_cell, bottom_cell)
	else:
		var types: Vector3 = Vector3(bottom_cell.terrain, left_cell.terrain, right_cell.terrain)
		self.terrain.add_triangle_fan(bottom, left, right, splat_color_1, splat_color_2, splat_color_3, types)

func add_corner_terraces(begin: Vector3, left: Vector3, right: Vector3, begin_cell: HexCell, left_cell: HexCell, right_cell: HexCell):
	var v3: Vector3 = HexMetrics.terrace_lerp(begin, left, 1)
	var v4: Vector3 = HexMetrics.terrace_lerp(begin, right, 1)
	var c3: Color = HexMetrics.terrace_lerp_color(splat_color_1, splat_color_2, 1)
	var c4: Color = HexMetrics.terrace_lerp_color(splat_color_1, splat_color_3, 1)
	var types: Vector3 = Vector3(begin_cell.terrain, left_cell.terrain, right_cell.terrain)
	
	self.terrain.add_triangle_fan(begin, v3, v4, splat_color_1, c3, c4, types)
	
	for i in range(2, HexMetrics.TERRACE_STEPS):
		var v1: Vector3 = v3
		var v2: Vector3 = v4
		var c1: Color = c3
		var c2: Color = c4
		v3 = HexMetrics.terrace_lerp(begin, left, i)
		v4 = HexMetrics.terrace_lerp(begin, right, i)
		c3 = HexMetrics.terrace_lerp_color(splat_color_1, splat_color_2, i)
		c4 = HexMetrics.terrace_lerp_color(splat_color_1, splat_color_3, i)
		self.terrain.add_quad(v1, v2, v3, v4, c1, c2, c3, c4, types)
	
	self.terrain.add_quad(v3, v4, left, right, c3, c4, splat_color_2, splat_color_3, types)

func add_corner_terraces_cliff(begin: Vector3, left: Vector3, right: Vector3, begin_cell: HexCell, left_cell: HexCell, right_cell: HexCell):
	var b: float = 1.0 / (right_cell.elevation - begin_cell.elevation)
	if b < 0:
		b = -b
	
	var boundary: Vector3 = HexMetrics.perturb(begin).lerp(HexMetrics.perturb(right), b)
	var boundary_color: Color = splat_color_1.lerp(splat_color_3, b)
	var types: Vector3 = Vector3(begin_cell.terrain, left_cell.terrain, right_cell.terrain)
	
	add_boundary_triangle(begin, left, boundary, splat_color_1, splat_color_2, boundary_color, types)
	
	if left_cell.get_edge_type_from_cell(right_cell) == Hex.EdgeType.Slope:
		add_boundary_triangle(left, right, boundary, splat_color_2, splat_color_3, boundary_color, types)
	else:
		self.terrain.add_triangle_fan(HexMetrics.perturb(left), HexMetrics.perturb(right), boundary, splat_color_2, splat_color_3, boundary_color, types, false)

func add_corner_cliff_terraces(begin: Vector3, left: Vector3, right: Vector3, begin_cell: HexCell, left_cell: HexCell, right_cell: HexCell):
	var b: float = 1.0 / (left_cell.elevation - begin_cell.elevation)
	if b < 0:
		b = -b
	
	var boundary: Vector3 = HexMetrics.perturb(begin).lerp(HexMetrics.perturb(left), b)
	var boundary_color: Color = splat_color_1.lerp(splat_color_2, b)
	var types: Vector3 = Vector3(begin_cell.terrain, left_cell.terrain, right_cell.terrain)
	
	add_boundary_triangle(right, begin, boundary, splat_color_3, splat_color_1, boundary_color, types)
	
	if left_cell.get_edge_type_from_cell(right_cell) == Hex.EdgeType.Slope:
		add_boundary_triangle(left, right, boundary, splat_color_2, splat_color_3, boundary_color, types)
	else:
		self.terrain.add_triangle_fan(HexMetrics.perturb(left), HexMetrics.perturb(right), boundary, splat_color_2, splat_color_3, boundary_color, types, false)

func add_boundary_triangle(begin: Vector3, left: Vector3, boundary: Vector3, begin_color: Color, left_color: Color, boundary_color: Color, types: Vector3):
	var v2: Vector3 = HexMetrics.perturb(HexMetrics.terrace_lerp(begin, left, 1))
	var c2: Color = HexMetrics.terrace_lerp_color(begin_color, left_color, 1)
	
	self.terrain.add_triangle_fan(HexMetrics.perturb(begin), v2, boundary, begin_color, c2, boundary_color, types, false)
	
	for i in range(2, HexMetrics.TERRACE_STEPS):
		var v1: Vector3 = v2
		var c1: Color = c2
		v2 = HexMetrics.perturb(HexMetrics.terrace_lerp(begin, left, i))
		c2 = HexMetrics.terrace_lerp_color(begin_color, left_color, i)
		self.terrain.add_triangle_fan(v1, v2, boundary, c1, c2, boundary_color, types, false)
	
	self.terrain.add_triangle_fan(v2, HexMetrics.perturb(left), boundary, c2, left_color, boundary_color, types, false)

func add_water(dir: int, cell: HexCell, center: Vector3):
	var water_center = Vector3(center)
	water_center.y = cell.water_surface_y()
	
	var neighbor: HexCell = cell.get_neighbor(dir, null)
	if neighbor and !neighbor.is_under_water():
		add_shore_water(dir, cell, neighbor, water_center)
	else:
		add_open_water(dir, cell, neighbor, water_center)

func add_open_water(dir: int, cell: HexCell, neighbor: HexCell, center: Vector3):
	var c1: Vector3 = center + HexMetrics.get_first_solid_corner(dir)
	var c2: Vector3 = center + HexMetrics.get_second_solid_corner(dir)
	var color: Color = Color.WHITE
	self.water.add_triangle_fan(center, c1, c2, color, color, color, Vector3())
	
	if dir <= Hex.Direction.SE and neighbor:
		var bridge: Vector3 = HexMetrics.get_bridge(dir)
		var e1: Vector3 = c1 + bridge
		var e2: Vector3 = c2 + bridge
		self.water.add_quad(c1, c2, e1, e2, color, color, color, color, Vector3())
		if dir <= Hex.Direction.E:
			var next_neighbor: HexCell = cell.get_neighbor(Hex.next_dir(dir), null)
			if !next_neighbor or !next_neighbor.is_under_water():
				return
			self.water.add_triangle_fan(c2, e2, c2 + HexMetrics.get_bridge(Hex.next_dir(dir)), color, color, color, Vector3())

func add_shore_water(dir: int, cell: HexCell, neighbor: HexCell, center: Vector3):
	var e1: EdgeVertices = EdgeVertices.new(center + HexMetrics.get_first_solid_corner(dir), center + HexMetrics.get_second_solid_corner(dir))
	self.water.add_triangle_fan(center, e1.v1, e1.v2, Color.WHITE, Color.WHITE, Color.WHITE, Vector3())
	self.water.add_triangle_fan(center, e1.v2, e1.v3, Color.WHITE, Color.WHITE, Color.WHITE, Vector3())
	self.water.add_triangle_fan(center, e1.v3, e1.v4, Color.WHITE, Color.WHITE, Color.WHITE, Vector3())
	self.water.add_triangle_fan(center, e1.v4, e1.v5, Color.WHITE, Color.WHITE, Color.WHITE, Vector3())
	
	var bridge: Vector3 = HexMetrics.get_bridge(dir)
	var e2: EdgeVertices = EdgeVertices.new(e1.v1 + bridge, e1.v5 + bridge)
	self.water.add_quad(e1.v1, e1.v2, e2.v1, e2.v2, Color.WHITE, Color.WHITE, Color.WHITE, Color.WHITE, Vector3())
	self.water.add_quad(e1.v2, e1.v3, e2.v2, e2.v3, Color.WHITE, Color.WHITE, Color.WHITE, Color.WHITE, Vector3())
	self.water.add_quad(e1.v3, e1.v4, e2.v3, e2.v4, Color.WHITE, Color.WHITE, Color.WHITE, Color.WHITE, Vector3())
	self.water.add_quad(e1.v4, e1.v5, e2.v4, e2.v5, Color.WHITE, Color.WHITE, Color.WHITE, Color.WHITE, Vector3())
	
	var next_neighor: HexCell = cell.get_neighbor(Hex.next_dir(dir), null)
	if next_neighor:
		self.water.add_triangle_fan(e1.v5, e2.v5, e1.v5 + HexMetrics.get_bridge(Hex.next_dir(dir)), Color.WHITE, Color.WHITE, Color.WHITE, Vector3())
