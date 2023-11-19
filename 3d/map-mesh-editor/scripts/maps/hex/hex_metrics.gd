class_name HexMetrics

const CHUNK_SIZE_X: int = 5
const CHUNK_SIZE_Z: int = 5

const OUTER_RADIUS: float = 2
const INNER_RADIUS: float = HexMetrics.OUTER_RADIUS * 0.866025404

const SOLID_FACTOR: float = 0.8
const BLEND_FACTOR: float = 1.0 - HexMetrics.SOLID_FACTOR

const ELEVATION_STEP: float = 0.5
const TERRACES_PER_SLOPE: int = 2
const TERRACE_STEPS = HexMetrics.TERRACES_PER_SLOPE * 2 + 1
const HORZ_TERRACE_STEP_SIZE: float = 1.0 / HexMetrics.TERRACE_STEPS
const VERT_TERRACE_STEP_SIZE: float = 1.0 / (HexMetrics.TERRACES_PER_SLOPE + 1)

const CELL_PERTURB_STRENGTH: float = 0.8
const ELEVATION_PERTURB_STRENGTH: float = 0.5

const WATER_ELEVATION_OFFSET: float = -0.5

# Corners are ordered around the center of the hexagon as follows:
# IMPORTANT: these are in clockwise winding order if viewed from the top
# Y coordinate is always 0 since the cells are flat and facing up
#      0
#     / \
#   /     \
#  5       1
#  |       |
#  | (0,0) |
#  4       2
#   \     /
#     \ /
#      3
const CORNERS: Array[Vector3] = [
	Vector3(0, 0, -OUTER_RADIUS),
	Vector3(INNER_RADIUS, 0, -0.5 * OUTER_RADIUS),
	Vector3(INNER_RADIUS, 0, 0.5 * OUTER_RADIUS),
	Vector3(0, 0, OUTER_RADIUS),
	Vector3(-INNER_RADIUS, 0, 0.5 * OUTER_RADIUS),
	Vector3(-INNER_RADIUS, 0, -0.5 * OUTER_RADIUS)
]

# Neighbors are ordered from top right then going clockwise
const CELL_NEIGHBORS: Array[Vector3] = [
	Vector3(1,0,-1),
	Vector3(1,-1,0),
	Vector3(0,-1,1),
	Vector3(-1,0,1),
	Vector3(-1,1,0),
	Vector3(0,1,-1)
]

static func get_first_corner(i: int) -> Vector3:
	return HexMetrics.CORNERS[i]

static func get_second_corner(i: int) -> Vector3:
	return HexMetrics.CORNERS[(i + 1) % 6]

static func get_first_solid_corner(i: int) -> Vector3:
	return get_first_corner(i) * HexMetrics.SOLID_FACTOR

static func get_second_solid_corner(i: int) -> Vector3:
	return get_second_corner(i) * HexMetrics.SOLID_FACTOR

static func get_bridge(i: int) -> Vector3:
	return (get_first_corner(i) + get_second_corner(i)) * HexMetrics.BLEND_FACTOR

static func terrace_lerp(a: Vector3, b: Vector3, step: int) -> Vector3:
	var h: float = step * HexMetrics.HORZ_TERRACE_STEP_SIZE
	a.x += (b.x - a.x) * h
	a.z += (b.z - a.z) * h
	var v: float = ((step + 1) / 2) * HexMetrics.VERT_TERRACE_STEP_SIZE
	a.y += (b.y - a.y) * v
	return a

static func terrace_lerp_color(a: Color, b: Color, step: int) -> Color:
	var h: float = step * HexMetrics.HORZ_TERRACE_STEP_SIZE
	return a.lerp(b, h)

static func get_edge_type(el1: int, el2: int) -> Hex.EdgeType:
	if el1 == el2:
		return Hex.EdgeType.Flat
	var delta: int = el2 - el1
	if delta == 1 || delta == -1:
		return Hex.EdgeType.Slope
	return Hex.EdgeType.Cliff

static func perturb(pos: Vector3) -> Vector3:
	var sample: Vector3 = HexNoise.sample(pos)
	pos.x += (sample.x * 2.0 - 1.0) * HexMetrics.CELL_PERTURB_STRENGTH
	pos.z += (sample.z * 2.0 - 1.0) * HexMetrics.CELL_PERTURB_STRENGTH
	return pos
