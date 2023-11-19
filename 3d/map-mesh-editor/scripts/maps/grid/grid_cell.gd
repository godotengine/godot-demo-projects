class_name GridCell extends Node3D

@onready var label: Label3D = $Label3D

var chunk_id: int = -1
var coords: GridCoordinates
var neighbors: Array[GridCell] = [null, null, null, null, null, null, null, null]

var elevation: int = -1 :
	get:
		return elevation
	set(value):
		if elevation == value:
			return
		elevation = value
		position.y = elevation * GridMetrics.ELEVATION_STEP
		refresh()

var terrain: int = 0 :
	get:
		return terrain
	set(value):
		terrain = value
		refresh()

signal changed

func _ready() -> void:
	self.label.text = str(coords)
#	self.label.visible = false
	GlobalCellEditor.connect("show_labels_updated", _on_editor_show_labels_updated)

func refresh() -> void:
	if self.chunk_id >= 0:
		refresh_self()
		for i in range(self.neighbors.size()):
			if self.neighbors[i] and self.neighbors[i].chunk_id != self.chunk_id:
				self.neighbors[i].refresh_self()

func refresh_self() -> void:
	emit_signal("changed")

func get_neighbor(dir: Cell.Direction, default_cell: GridCell = self):
	return self.neighbors[dir] if self.neighbors[dir] else default_cell

func get_neighbor_from_cardinal(dir: Cell.CardinalDirection, default_cell: GridCell = self):
	var equivalent_dir = Cell.EQUIVALENT_DIRECTION[dir]
	return self.neighbors[equivalent_dir] if self.neighbors[equivalent_dir] else default_cell

func get_edge_type(d: Cell.Direction) -> Cell.EdgeType:
	return GridMetrics.get_edge_type(self.elevation, get_neighbor(d).elevation)

func get_edge_type_from_cardinal(d: Cell.CardinalDirection) -> Cell.EdgeType:
	return GridMetrics.get_edge_type(self.elevation, get_neighbor_from_cardinal(d).elevation)

func get_edge_type_from_cell(c: GridCell) -> Cell.EdgeType:
	return GridMetrics.get_edge_type(self.elevation, c.elevation)

func get_elevation_diff(dir: Cell.Direction) -> int:
	var diff: int = self.elevation - get_neighbor(dir).elevation
	return diff if diff >= 0 else -diff 

func is_under_water() -> bool:
	return self.position.y < GridMetrics.SEA_LEVEL

func _on_editor_show_labels_updated():
	self.label.visible = GlobalCellEditor.debug_enabled and GlobalCellEditor.show_labels
