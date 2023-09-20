class_name HexGrid extends Node3D

const HEX_CELL = preload("res://objects/maps/hex/hex_cell.tscn")
const HEX_GRID_CHUNK = preload("res://objects/maps/hex/hex_grid_chunk.tscn")

@export_group("Size")
@export var chunk_count_x: int = 4
@export var chunk_count_z: int = 3

@export_group("Texture")
@export var textures: Array[Texture2D]

var cells: Array[HexCell] = []
var cell_dict: Dictionary = {}
var chunks: Array[HexGridChunk] = []
var _cell_count_x: int
var _cell_count_z: int
var _texture_arr: Texture2DArray

func _ready() -> void:
	self._cell_count_x = self.chunk_count_x * HexMetrics.CHUNK_SIZE_X
	self._cell_count_z = self.chunk_count_z * HexMetrics.CHUNK_SIZE_Z
	
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
			var chunk: HexGridChunk = self.HEX_GRID_CHUNK.instantiate()
			chunk.chunk_id = i
			chunk.texture_arr = _texture_arr
			chunk.set_name("Chunk" + str(i))
			chunk.connect("chunk_pressed", _on_chunk_pressed)
			self.chunks[i] = chunk
			add_child(chunk)
			i += 1

func _create_cells() -> void:
	self.cells.clear()
	self.cells.resize(self._cell_count_z * self._cell_count_x)
	self.cell_dict.clear()
	
	var i : int = 0
	for z in range(self._cell_count_z):
		for x in range(self._cell_count_x):
			var cell: HexCell = _create_cell(x, z)
			self.cell_dict[cell.coords.to_vec3()] = cell
			self.cells[i] = cell
			i += 1
	
	for c in range(self.cells.size()):
		var iv3 = self.cells[c].coords.to_vec3()
		for d in 6:
			var neighbor = iv3 + HexMetrics.CELL_NEIGHBORS[d]
			if self.cell_dict.has(neighbor):
				self.cells[c].neighbors[d] = self.cell_dict[neighbor]
			else:
				self.cells[c].neighbors[d] = null

func _create_cell(x: int, z: int) -> HexCell:
	var cell: HexCell = HEX_CELL.instantiate()
	cell.position = _get_cell_start_pos(x, z)
	cell.coords = HexCoordinates.from_offset_coords(x, z)
	cell.terrain = GlobalCellEditor.terrain
	cell.elevation = GlobalCellEditor.elevation
	cell.water_level = GlobalCellEditor.water
	cell.set_name("Cell" + str(cell.coords))
	_add_cell_to_chunk(x, z, cell)
	return cell

func _add_cell_to_chunk(x: int, z: int, cell: HexCell):
	var chunk_x: int = x / HexMetrics.CHUNK_SIZE_X
	var chunk_z: int = z / HexMetrics.CHUNK_SIZE_Z
	var chunk: HexGridChunk = self.chunks[chunk_x + chunk_z * self.chunk_count_x]
	
	var local_x: int = x - chunk_x * HexMetrics.CHUNK_SIZE_X
	var local_z: int = z - chunk_z * HexMetrics.CHUNK_SIZE_Z
	
	chunk.add_cell(local_x + local_z * HexMetrics.CHUNK_SIZE_X, cell)

func _refresh():
	for i in range(self.chunks.size()):
		self.chunks[i].refresh()

func _get_cell(v: Vector3) -> HexCell:
	var coords: HexCoordinates = HexCoordinates.from_position(v)
	var index: int = coords.x + coords.z * self._cell_count_x + coords.z / 2
	if index >= 0 and index < self.cells.size():
		var cell: HexCell = self.cells[index]
		return cell
	return null

func _get_cell_from_hexcoords(coords: HexCoordinates) -> HexCell:
	var z: int = coords.z
	var x: int = coords.x + z / 2
	return self.cells[x + z * self._cell_count_x]

func _get_cell_start_pos(x: int, z: int) -> Vector3:
	var pos : Vector3 = Vector3()
	pos.x = (x + z * 0.5 - z / 2) * (HexMetrics.INNER_RADIUS * 2.0)
	pos.z = z * (HexMetrics.OUTER_RADIUS * 1.5)
	return pos

func _edit_grid_cells(center_cell: HexCell) -> void:
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
			var coords: HexCoordinates = HexCoordinates.new(x, z)
			var next_cell: HexCell = _get_cell_from_hexcoords(coords)
			_edit_grid_cell(next_cell)
		r += 1
	r = 0
	for z in range(center_z + edit_radius, center_z, -1):
		for x in range(center_x - edit_radius, center_x + r + 1):
			var coords: HexCoordinates = HexCoordinates.new(x, z)
			var next_cell: HexCell = _get_cell_from_hexcoords(coords)
			_edit_grid_cell(next_cell)
		r += 1

func _edit_grid_cell(cell: HexCell) -> void:
	if !cell:
		return
	
	if GlobalCellEditor.terrain_enabled:
		cell.terrain = GlobalCellEditor.terrain
	
	if GlobalCellEditor.elevation_enabled:
		cell.elevation = GlobalCellEditor.elevation
	
	if GlobalCellEditor.water_enabled:
		cell.water_level = GlobalCellEditor.water

func _on_chunk_pressed(pos: Vector3) -> void:
	var curr_cell: HexCell = _get_cell(pos)
	if curr_cell:
		_edit_grid_cells(curr_cell)
