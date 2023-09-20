class_name GridCoordinates extends MapCoordinates

func _init(xx: int, zz: int):
	self.x = xx
	self.z = zz

func _to_string() -> String:
	return "(" + str(self.x) + ", " + str(self.z) + ")"
	
func _to_string_on_separate_lines() -> String:
	return str(self.x) + "\n" + str(self.z)

func to_vec3() -> Vector3:
	return Vector3(self.x, 0, self.z)

static func from_offset_coords(xx: float, zz: float) -> MapCoordinates:
	var coord_x: float = xx / GridMetrics.CELL_WIDTH
	var coord_z: float = zz / GridMetrics.CELL_WIDTH
	return GridCoordinates.new(coord_x, coord_z)

static func from_position(pos: Vector3) -> MapCoordinates:
	var in_x: float = pos.x
	var in_z: float = pos.z
	var coord_x: float = snapped(in_x, GridMetrics.CELL_WIDTH) / GridMetrics.CELL_WIDTH
	var coord_z: float = snapped(in_z, GridMetrics.CELL_WIDTH) / GridMetrics.CELL_WIDTH * -1
	var grid_coords: GridCoordinates = GridCoordinates.new(coord_x, coord_z)
	print("Converting " + str(pos) + " to " + str(grid_coords))
	return grid_coords
