class_name GridMetrics

const CHUNK_SIZE_X: int = 3 #5
const CHUNK_SIZE_Z: int = 3 #5

const CELL_RADIUS: float = 5.5
const CELL_CORNER_RADIUS: float = CELL_RADIUS
const CELL_WIDTH: float = CELL_RADIUS * 2.0

const SOLID_FACTOR: float = 0.8
const BLEND_FACTOR: float = 1.0 - SOLID_FACTOR

const ELEVATION_STEP: float = 1

const TERRACES_PER_SLOPE: int = 2
const TERRACE_STEPS = TERRACES_PER_SLOPE * 2 + 1
const HORZ_TERRACE_STEP_SIZE: float = 1.0 / TERRACE_STEPS
const VERT_TERRACE_STEP_SIZE: float = 1.0 / (TERRACES_PER_SLOPE + 1)

const CELL_PERTURB_STRENGTH: float = 2
const ELEVATION_PERTURB_STRENGTH: float = 2.5

const SEA_LEVEL: float = ELEVATION_STEP * 2

# Corners are ordered around the center of the square as follows:
# IMPORTANT: these are in clockwise winding order if viewed from the top
# Y coordinate is always 0 since the cells are flat and facing up
#  7 - - - - 0 - - - - 1
#  |         |         |
#  |         |         |
#  |         |         |
# 6 - - - (0,0) - - - 2
#  |         |         |
#  |         |         |
#  |         |         |
#  5 - - - - 4 - - - - 3
##
#const CORNERS: Array[Vector3] = [
#	Vector3(0, 0, -CELL_RADIUS),					# N
#	Vector3(CELL_RADIUS, 0, -CELL_CORNER_RADIUS),	# NE
#	Vector3(CELL_RADIUS, 0, 0),						# E
#	Vector3(CELL_RADIUS, 0, CELL_CORNER_RADIUS),	# SE
#	Vector3(0, 0, CELL_RADIUS),						# S
#	Vector3(-CELL_RADIUS, 0, CELL_CORNER_RADIUS),   # SW
#	Vector3(-CELL_RADIUS, 0, 0),					# W
#	Vector3(-CELL_RADIUS, 0, -CELL_CORNER_RADIUS)	# NW
#]

const CORNERS: Array[Vector3] = [
	Vector3(-CELL_RADIUS, 0, -CELL_CORNER_RADIUS),
	Vector3(CELL_RADIUS, 0, -CELL_CORNER_RADIUS),
	Vector3(CELL_RADIUS, 0, CELL_CORNER_RADIUS),
	Vector3(-CELL_RADIUS, 0, CELL_CORNER_RADIUS),
]

# Neighbors are ordered from top then going clockwise
const CELL_NEIGHBORS: Array[Vector3] = [
	Vector3(0,0,1),	# N
	Vector3(1,0,1),	# NE
	Vector3(1,0,0),		# E
	Vector3(1,0,-1),		# SE
	Vector3(0,0,-1),		# S
	Vector3(-1,0,-1),	# SW
	Vector3(-1,0,0),	# W
	Vector3(-1,0,1)	# NW
]

static func get_first_corner(i: int) -> Vector3:
	return GridMetrics.CORNERS[i]

static func get_second_corner(i: int) -> Vector3:
	return GridMetrics.CORNERS[(i + 1) % 4]

static func get_first_solid_corner(dir: Cell.CardinalDirection) -> Vector3:
	return get_first_corner(dir) * GridMetrics.SOLID_FACTOR

static func get_second_solid_corner(dir: Cell.CardinalDirection) -> Vector3:
	return get_second_corner(dir) * GridMetrics.SOLID_FACTOR

static func get_bridge(dir: Cell.CardinalDirection) -> Vector3:
	return (get_first_corner(dir) + get_second_corner(dir)) * GridMetrics.BLEND_FACTOR

static func get_bridge_non_cardinal(dir: Cell.Direction) -> Vector3:
	var prev_cardinal_dir: Cell.CardinalDirection
	return Vector3()

static func terrace_lerp(a: Vector3, b: Vector3, step: int) -> Vector3:
	var h: float = step * GridMetrics.HORZ_TERRACE_STEP_SIZE
	a.x += (b.x - a.x) * h
	a.z += (b.z - a.z) * h
	var v: float = ((step + 1) / 2) * GridMetrics.VERT_TERRACE_STEP_SIZE
	a.y += (b.y - a.y) * v
	return a

static func terrace_lerp_color(a: Color, b: Color, step: int) -> Color:
	var h: float = step * GridMetrics.HORZ_TERRACE_STEP_SIZE
	return a.lerp(b, h)

static func get_edge_type(el1: int, el2: int) -> Cell.EdgeType:
	if el1 == el2:
		return Cell.EdgeType.Flat
	var delta: int = el2 - el1
	if delta == 1 || delta == -1:
		return Cell.EdgeType.Slope
	return Cell.EdgeType.Cliff

static func perturb(pos: Vector3) -> Vector3:
	var sample: Vector3 = CellNoise.sample(pos)
	pos.x += (sample.x * 2.0 - 1.0) * GridMetrics.CELL_PERTURB_STRENGTH
	pos.z += (sample.z * 2.0 - 1.0) * GridMetrics.CELL_PERTURB_STRENGTH
	return pos
