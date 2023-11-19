class_name Grid extends Node3D

const GRID_CELL = preload("res://objects/maps/grid/grid_cell.tscn")
const GRID_CHUNK = preload("res://objects/maps/grid/grid_chunk.tscn")

@export_group("Size")
@export var chunk_count_x: int = 4
@export var chunk_count_z: int = 3

@export_group("Texture")
@export var textures: Array[Texture2D]

var cells: Array[GridCell] = []
var cell_dict: Dictionary = {}
var chunks: Array[GridChunk] = []

var _cell_count_x: int
var _cell_count_z: int

var _texture_arr: Texture2DArray

func _ready():
	self._cell_count_x = self.chunk_count_x * GridMetrics.CHUNK_SIZE_X
	self._cell_count_z = self.chunk_count_z * GridMetrics.CHUNK_SIZE_Z
	
	# Create splat map
	var img_arr: Array[Image] = []
	for i in range(textures.size()):
		if textures[i]:
			img_arr.push_back(textures[i].get_image())
	self._texture_arr = Texture2DArray.new()
	self._texture_arr.create_from_images(img_arr)

func build_grid() -> void:
	_create_chunks()
	_create_cells()
	_refresh()

func _create_chunks() -> void:
	self.chunks.clear()
	self.chunks.resize(self.chunk_count_x * self.chunk_count_z)

	var i: int = 0
	for z in range(self.chunk_count_z):
		for x in range(self.chunk_count_x):
			var new_chunk: GridChunk = self.GRID_CHUNK.instantiate()
			new_chunk.chunk_id = i
			new_chunk.texture_arr = self._texture_arr
			new_chunk.set_name("Chunk" + str(i))
			new_chunk.connect("chunk_pressed", _on_chunk_pressed)
			self.chunks[i] = new_chunk
			add_child(new_chunk)
			i += 1

func _create_cells() -> void:
	self.cells.clear()
	self.cells.resize(self._cell_count_z * self._cell_count_x)
	self.cell_dict.clear()
	
	var i : int = 0
	for z in range(self._cell_count_z):
		for x in range(self._cell_count_x):
			var cell: GridCell = _create_cell(x, z)
			self.cell_dict[cell.coords.to_vec3()] = cell
			self.cells[i] = cell
			i += 1
	
	for c in range(self.cells.size()):
		var iv3 = self.cells[c].coords.to_vec3()
		for dir in range(Cell.Direction.size()):
			var neighbor = iv3 + GridMetrics.CELL_NEIGHBORS[dir]
			if self.cell_dict.has(neighbor):
				self.cells[c].neighbors[dir] = self.cell_dict[neighbor]
			else:
				self.cells[c].neighbors[dir] = null

func _create_cell(x: int, z: int) -> GridCell:
	var cell: GridCell = self.GRID_CELL.instantiate()
	cell.position = _get_cell_start_pos(x, z)
	cell.coords = GridCoordinates.new(x, z)
	cell.terrain = GlobalCellEditor.terrain
	cell.elevation = GlobalCellEditor.elevation
	cell.set_name("Cell" + str(cell.coords))
	_add_cell_to_chunk(x, z, cell)
	return cell

func _add_cell_to_chunk(x: int, z: int, cell: GridCell):
	var chunk_x: int = x / GridMetrics.CHUNK_SIZE_X
	var chunk_z: int = z / GridMetrics.CHUNK_SIZE_Z
	var chunk: GridChunk = self.chunks[chunk_x + chunk_z * self.chunk_count_x]
	
	var local_x: int = x - chunk_x * GridMetrics.CHUNK_SIZE_X
	var local_z: int = z - chunk_z * GridMetrics.CHUNK_SIZE_Z
	
	chunk.add_cell(local_x + local_z * GridMetrics.CHUNK_SIZE_X, cell)

func _refresh():
	for i in range(self.chunks.size()):
		self.chunks[i].refresh()

func _get_cell(v: Vector3) -> GridCell:
	var coords: GridCoordinates = GridCoordinates.from_position(v)
	var index: int = coords.x + coords.z * self._cell_count_x
	if index >= 0 and index < self.cells.size():
		var cell: GridCell = self.cells[index]
		return cell
	return null

func _get_cell_from_coords(coords: GridCoordinates) -> GridCell:
	var z: int = coords.z
	var x: int = coords.x
	return self.cells[x + z * self._cell_count_x]

func _get_cell_start_pos(x: int, z: int) -> Vector3:
	var pos : Vector3 = Vector3()
	pos.x = x * GridMetrics.CELL_WIDTH
	pos.z = z * GridMetrics.CELL_WIDTH * -1
	return pos

func _edit_grid_cells(center_cell: GridCell) -> void:
	if !center_cell or !GlobalCellEditor.brush_enabled:
		return
	
	var edit_radius = GlobalCellEditor.brush_size
	
	if edit_radius == 0:
		_edit_grid_cell(center_cell)
		return
	
	var center_x: int = center_cell.coords.x
	var center_z: int = center_cell.coords.z
	
	var r: int = 0
	for z in range(center_z - edit_radius, center_z + 1):
		for x in range(center_x - r, center_x + edit_radius + 1):
			var coords: GridCoordinates = GridCoordinates.new(x, z)
			var next_cell: GridCell = _get_cell_from_coords(coords)
			_edit_grid_cell(next_cell)
		r += 1
	r = 0
	for z in range(center_z + edit_radius, center_z, -1):
		for x in range(center_x - edit_radius, center_x + r + 1):
			var coords: GridCoordinates = GridCoordinates.new(x, z)
			var next_cell: GridCell = _get_cell_from_coords(coords)
			_edit_grid_cell(next_cell)
		r += 1

func _edit_grid_cell(cell: GridCell) -> void:
	if !cell:
		return
	
	if GlobalCellEditor.terrain_enabled:
		cell.terrain = GlobalCellEditor.terrain
	
	if GlobalCellEditor.elevation_enabled:
		cell.elevation = GlobalCellEditor.elevation

func _on_chunk_pressed(pos: Vector3) -> void:
	var curr_cell: GridCell = _get_cell(pos)
	if curr_cell:
		_edit_grid_cells(curr_cell)
