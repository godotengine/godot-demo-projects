class_name GridChunk extends StaticBody3D

const splat_color_1: Color = Color(1, 0, 0)
const splat_color_2: Color = Color(0, 1, 0)
const splat_color_3: Color = Color(0, 0, 1)

@onready var terrain: GeneratedMesh = $GeneratedMeshTerrain

var chunk_id: int = -1
var texture_arr: Texture2DArray
var shape_owner_id: int
var shape: Shape3D
var cells: Array[GridCell] = []
var dirty: bool = false

signal chunk_pressed(pos: Vector3)

func _ready() -> void:
	self.terrain.perturb_func = func(v): return GridMetrics.perturb(v)
#	self.terrain.disable_all_perturb = true
	
	self.shape_owner_id = create_shape_owner(self)
	self.cells.clear()
	self.cells.resize(GridMetrics.CHUNK_SIZE_X * GridMetrics.CHUNK_SIZE_Z)
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
	
	for c in range(self.cells.size()):
#		self.cells[c].position.y += c * GridMetrics.ELEVATION_STEP # DEBUG
		add_cell_mesh(self.cells[c])
	
	self.shape = self.terrain.apply()
	shape_owner_add_shape(self.shape_owner_id, self.shape)

func add_cell(i: int, cell: GridCell):
	self.cells[i] = cell
	cell.connect("changed", _cell_changed)
	cell.chunk_id = self.chunk_id
	add_child(cell)

func _cell_changed():
	refresh()

func add_cell_mesh(cell: GridCell):
	for i in 4:
		add_quadrant(cell, i)

func add_quadrant(
	cell: GridCell,
	dir: Cell.CardinalDirection
) -> void:
	var center: Vector3 = cell.position
	var first_corner: Vector3 = GridMetrics.get_first_corner(dir)
	var second_corner: Vector3 = GridMetrics.get_second_corner(dir)
#	var e: GridEdgeVertices = GridEdgeVertices.new(center + first_corner, center + second_corner)
	
	var v1: Vector3 = center + first_corner
	var v3: Vector3 = center + second_corner
	var v2: Vector3 = v1.lerp(v3, 0.5)
	
	var n1: GridCell = cell.get_neighbor_from_cardinal(dir, cell)
	var n2: GridCell = cell.get_neighbor(Cell.prev_dir_from_cardinal(dir), cell)
	var n3: GridCell = cell.get_neighbor_from_cardinal(Cell.prev_cardinal_dir(dir), cell)
	var n4: GridCell = cell.get_neighbor(Cell.next_dir_from_cardinal(dir), cell)
	var n5: GridCell = cell.get_neighbor_from_cardinal(Cell.next_cardinal_dir(dir), cell)
	var n6: GridCell = cell.get_neighbor_from_cardinal(Cell.opposite_cardinal_dir(dir), cell)
	
	var height_a: float = [cell.elevation, n1.elevation, n2.elevation, n3.elevation].max()
	var height_b: float = [cell.elevation, n1.elevation, n4.elevation, n5.elevation].max()
	var height_c: float = maxf(cell.elevation, n1.elevation)
	
	var new_v1: Vector3 = Vector3(v1.x, height_a, v1.z)
	var new_v3: Vector3 = Vector3(v3.x, height_b, v3.z)
	var new_v2: Vector3 = Vector3(v2.x, height_c, v2.z)
	
	var height: float = (cell.elevation + n1.elevation + n3.elevation + n5.elevation + n6.elevation) / 5.0
	var new_center: Vector3 = Vector3(center.x, height, center.z)
	
	self.terrain.add_triangle_fan(center, new_v1, new_v2, splat_color_1, splat_color_2, splat_color_3, Vector3(cell.terrain, n2.terrain, n1.terrain))
	self.terrain.add_triangle_fan(center, new_v2, new_v3, splat_color_1, splat_color_2, splat_color_3, Vector3(cell.terrain, n1.terrain, n4.terrain))
	
#	self.terrain.add_edge_fan(center, e, splat_color_1, cell.terrain)
#	if Cell.requires_connection_mesh(dir):
#		add_connection(cell, dir, e)

func add_connection(
	cell: GridCell,
	dir: Cell.CardinalDirection,
	e1: GridEdgeVertices
) -> void:
	var neighbor: GridCell = cell.get_neighbor_from_cardinal(dir, null)
	if !neighbor:
		return
	
	# Calculate bridge
	var bridge: Vector3 = GridMetrics.get_bridge(dir)
	bridge.y = neighbor.position.y - cell.position.y
	
	var e2: GridEdgeVertices = GridEdgeVertices.new(e1.v1 + bridge, e1.v5 + bridge)
	
	if cell.get_edge_type_from_cardinal(dir) == Cell.EdgeType.Slope:
		add_edge_terraces(e1, e2, cell, neighbor)
	else:
		self.terrain.add_edge_strip(e1, e2, splat_color_1, splat_color_2, cell.terrain, neighbor.terrain)
	
	# Calculate corners
	if Cell.requires_corner_mesh(dir):
		var north_east_neighbor: GridCell = cell.get_neighbor(Cell.next_dir_from_cardinal(dir), null)
		if north_east_neighbor:
			var v5: Vector3 = e1.v5 + GridMetrics.get_bridge(Cell.next_cardinal_dir(dir))
			v5.y = north_east_neighbor.position.y
			
			if cell.elevation <= neighbor.elevation:
				if cell.elevation <= north_east_neighbor.elevation:
					add_corner(e1.v5, e2.v5, v5, cell, neighbor, north_east_neighbor)
				else:
					add_corner(v5, e1.v5, e2.v5, north_east_neighbor, cell, neighbor)
			elif neighbor.elevation <= north_east_neighbor.elevation:
				add_corner(e2.v5, v5, e1.v5, neighbor, north_east_neighbor, cell)
			else:
				add_corner(v5, e1.v5, e2.v5, north_east_neighbor, cell, neighbor)
		
		var north_west_neighbor: GridCell = cell.get_neighbor(Cell.prev_dir_from_cardinal(dir), null)
		if north_west_neighbor:
			var nw_bridge: Vector3 = GridMetrics.get_bridge(Cell.prev_cardinal_dir(dir))
			var v5: Vector3 = e1.v1 + nw_bridge + bridge
			v5.y = north_west_neighbor.position.y
			
			if cell.elevation <= neighbor.elevation:
				if cell.elevation <= north_west_neighbor.elevation:
					return
					add_corner(v5, e2.v1, e1.v1, north_west_neighbor, neighbor, cell)
				else:
					return
					add_corner(v5, e1.v1, e2.v5, north_west_neighbor, cell, neighbor)
			elif neighbor.elevation <= north_west_neighbor.elevation:
				return
				add_corner(e2.v1, v5, e1.v1, neighbor, north_west_neighbor, cell)
			else:
				add_corner(v5, e1.v1, e2.v1, north_west_neighbor, cell, neighbor)

func add_edge_terraces(
	begin: GridEdgeVertices,
	end: GridEdgeVertices,
	begin_cell: GridCell,
	end_cell: GridCell
) -> void:
	var e2: GridEdgeVertices = begin.terrace_lerp(end, 1)
	var c2: Color = GridMetrics.terrace_lerp_color(splat_color_1, splat_color_2, 1)
	var t1: float = begin_cell.terrain
	var t2: float = end_cell.terrain
	
	self.terrain.add_edge_strip(begin, e2, splat_color_1, c2, t1, t2)
	
	for i in range(2, GridMetrics.TERRACE_STEPS):
		var e1: GridEdgeVertices = e2
		var c1: Color = c2
		e2 = begin.terrace_lerp(end, i)
		c2 = GridMetrics.terrace_lerp_color(splat_color_1, splat_color_2, i)
		self.terrain.add_edge_strip(e1, e2, c1, c2, t1, t2)
	
	self.terrain.add_edge_strip(e2, end, c2, splat_color_2, t1, t2)

func add_corner(
	bottom: Vector3,
	left: Vector3,
	right: Vector3,
	bottom_cell: GridCell,
	left_cell: GridCell,
	right_cell: GridCell
) -> void:
	var left_edge_type: Cell.EdgeType = bottom_cell.get_edge_type_from_cell(left_cell)
	var right_edge_type: Cell.EdgeType = bottom_cell.get_edge_type_from_cell(right_cell)
	
	if left_edge_type == Cell.EdgeType.Slope:
		if right_edge_type == Cell.EdgeType.Slope:
			add_corner_terraces(bottom, left, right, bottom_cell, left_cell, right_cell)
		elif right_edge_type == Cell.EdgeType.Flat:
			add_corner_terraces(left, right, bottom, left_cell, right_cell, bottom_cell)
		else:
			add_corner_terraces_cliff(bottom, left, right, bottom_cell, left_cell, right_cell)
	elif right_edge_type == Cell.EdgeType.Slope:
		if left_edge_type == Cell.EdgeType.Flat:
			add_corner_terraces(right, bottom, left, right_cell, bottom_cell, left_cell)
		else:
			add_corner_cliff_terraces(bottom, left, right, bottom_cell, left_cell, right_cell)
	elif left_cell.get_edge_type_from_cell(right_cell) == Cell.EdgeType.Slope:
		if left_cell.elevation < right_cell.elevation:
			add_corner_cliff_terraces(right, bottom, left, right_cell, bottom_cell, left_cell)
		else:
			add_corner_terraces_cliff(left, right, bottom, left_cell, right_cell, bottom_cell)
	else:
		var types: Vector3 = Vector3(bottom_cell.terrain, left_cell.terrain, right_cell.terrain)
		self.terrain.add_triangle_fan(bottom, left, right, splat_color_1, splat_color_2, splat_color_3, types)

func add_corner_terraces(
	begin: Vector3,
	left: Vector3,
	right: Vector3,
	begin_cell: GridCell,
	left_cell: GridCell,
	right_cell: GridCell
) -> void:
	var v3: Vector3 = GridMetrics.terrace_lerp(begin, left, 1)
	var v4: Vector3 = GridMetrics.terrace_lerp(begin, right, 1)
	var c3: Color = GridMetrics.terrace_lerp_color(splat_color_1, splat_color_2, 1)
	var c4: Color = GridMetrics.terrace_lerp_color(splat_color_1, splat_color_3, 1)
	var types: Vector3 = Vector3(begin_cell.terrain, left_cell.terrain, right_cell.terrain)
	
	self.terrain.add_triangle_fan(begin, v3, v4, splat_color_1, c3, c4, types)
	
	for i in range(2, GridMetrics.TERRACE_STEPS):
		var v1: Vector3 = v3
		var v2: Vector3 = v4
		var c1: Color = c3
		var c2: Color = c4
		v3 = GridMetrics.terrace_lerp(begin, left, i)
		v4 = GridMetrics.terrace_lerp(begin, right, i)
		c3 = GridMetrics.terrace_lerp_color(splat_color_1, splat_color_2, i)
		c4 = GridMetrics.terrace_lerp_color(splat_color_1, splat_color_3, i)
		self.terrain.add_quad(v1, v2, v3, v4, c1, c2, c3, c4, types)
	
	self.terrain.add_quad(v3, v4, left, right, c3, c4, splat_color_2, splat_color_3, types)

func add_corner_terraces_cliff(
	begin: Vector3,
	left: Vector3,
	right: Vector3,
	begin_cell: GridCell,
	left_cell: GridCell,
	right_cell: GridCell
) -> void:
	var b: float = 1.0 / (right_cell.elevation - begin_cell.elevation)
	if b < 0:
		b = -b
	
	var boundary: Vector3 = GridMetrics.perturb(begin).lerp(GridMetrics.perturb(right), b)
	var boundary_color: Color = splat_color_1.lerp(splat_color_3, b)
	var types: Vector3 = Vector3(begin_cell.terrain, left_cell.terrain, right_cell.terrain)
	
	add_boundary_triangle(begin, left, boundary, splat_color_1, splat_color_2, boundary_color, types)
	
	if left_cell.get_edge_type_from_cell(right_cell) == Cell.EdgeType.Slope:
		add_boundary_triangle(left, right, boundary, splat_color_2, splat_color_3, boundary_color, types)
	else:
		self.terrain.add_triangle_fan(
			GridMetrics.perturb(left), GridMetrics.perturb(right),
			boundary, splat_color_2, splat_color_3, boundary_color, types, false)

func add_corner_cliff_terraces(
	begin: Vector3,
	left: Vector3,
	right: Vector3,
	begin_cell: GridCell,
	left_cell: GridCell,
	right_cell: GridCell
) -> void:
	var b: float = 1.0 / (left_cell.elevation - begin_cell.elevation)
	if b < 0:
		b = -b
	
	var boundary: Vector3 = GridMetrics.perturb(begin).lerp(GridMetrics.perturb(left), b)
	var boundary_color: Color = splat_color_1.lerp(splat_color_2, b)
	var types: Vector3 = Vector3(begin_cell.terrain, left_cell.terrain, right_cell.terrain)
	
	add_boundary_triangle(right, begin, boundary, splat_color_3, splat_color_1, boundary_color, types)
	
	if left_cell.get_edge_type_from_cell(right_cell) == Cell.EdgeType.Slope:
		add_boundary_triangle(left, right, boundary, splat_color_2, splat_color_3, boundary_color, types)
	else:
		self.terrain.add_triangle_fan(
			GridMetrics.perturb(left), GridMetrics.perturb(right),
			boundary, splat_color_2, splat_color_3, boundary_color, types, false)

func add_boundary_triangle(
	begin: Vector3,
	left: Vector3,
	boundary: Vector3,
	begin_color: Color,
	left_color: Color,
	boundary_color: Color,
	types: Vector3
) -> void:
	var v2: Vector3 = GridMetrics.perturb(GridMetrics.terrace_lerp(begin, left, 1))
	var c2: Color = GridMetrics.terrace_lerp_color(begin_color, left_color, 1)
	
	self.terrain.add_triangle_fan(GridMetrics.perturb(begin), v2, boundary, begin_color, c2, boundary_color, types, false)
	
	for i in range(2, GridMetrics.TERRACE_STEPS):
		var v1: Vector3 = v2
		var c1: Color = c2
		v2 = GridMetrics.perturb(GridMetrics.terrace_lerp(begin, left, i))
		c2 = GridMetrics.terrace_lerp_color(begin_color, left_color, i)
		self.terrain.add_triangle_fan(v1, v2, boundary, c1, c2, boundary_color, types, false)
	
	self.terrain.add_triangle_fan(v2, GridMetrics.perturb(left), boundary, c2, left_color, boundary_color, types, false)
