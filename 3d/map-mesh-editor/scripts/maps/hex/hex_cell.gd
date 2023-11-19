class_name HexCell extends Node3D

@onready var label : Label3D = $Label3D

var chunk_id: int = -1
var coords: HexCoordinates
var neighbors: Array[HexCell] = [null, null, null, null, null, null]

var elevation: int = -1 :
	get:
		return elevation
	set(value):
		if elevation == value:
			return
		elevation = value
		position.y = elevation * HexMetrics.ELEVATION_STEP
		position.y += (HexNoise.sample(position).y * 2.0 - 1.0) * HexMetrics.ELEVATION_PERTURB_STRENGTH
		refresh()

var terrain: int = 0 :
	get:
		return terrain
	set(value):
		terrain = value
		refresh()

var water_level: int :
	get:
		return water_level
	set(value):
		if water_level == value:
			return
		water_level = value
		refresh()

signal changed

func _ready() -> void:
	self.label.text = str(coords)
	self.label.visible = false
	GlobalCellEditor.connect("show_labels_updated", _on_editor_show_labels_updated)

func refresh():
	if self.chunk_id >= 0:
		refresh_self()
		for i in range(self.neighbors.size()):
			if self.neighbors[i] and self.neighbors[i].chunk_id != self.chunk_id:
				self.neighbors[i].refresh_self()

func refresh_self():
	emit_signal("changed")

func get_neighbor(dir: Hex.Direction, default_cell: HexCell = self):
	return self.neighbors[dir] if self.neighbors[dir] else default_cell

func get_edge_type(d: Hex.Direction) -> Hex.EdgeType:
	return HexMetrics.get_edge_type(self.elevation, get_neighbor(d).elevation)

func get_edge_type_from_cell(c: HexCell) -> Hex.EdgeType:
	return HexMetrics.get_edge_type(self.elevation, c.elevation)

func get_elevation_diff(dir: Hex.Direction) -> int:
	var diff: int = self.elevation - get_neighbor(dir).elevation
	return diff if diff >= 0 else -diff 

func is_under_water() -> bool:
	return self.water_level > self.elevation

func water_surface_y() -> float:
	return (self.water_level + HexMetrics.WATER_ELEVATION_OFFSET) * HexMetrics.ELEVATION_STEP

func _on_editor_show_labels_updated():
	self.label.visible = GlobalCellEditor.debug_enabled and GlobalCellEditor.show_labels
