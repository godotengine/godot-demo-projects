extends TileMap

enum Tile { OBSTACLE, START_POINT, END_POINT }

const CELL_SIZE = Vector2(64, 64)
const BASE_LINE_WIDTH = 3.0
const DRAW_COLOR = Color.WHITE

# The object for pathfinding on 2D grids.
var _astar = AStarGrid2D.new()
var _map_rect = Rect2i()

var _start_point = Vector2i()
var _end_point = Vector2i()
var _path = PackedVector2Array()

func _ready():
	# Let's assume that the entire map is located at non-negative coordinates.
	var map_size = get_used_rect().end
	_map_rect = Rect2i(Vector2i(), map_size)

	_astar.size = map_size
	_astar.cell_size = CELL_SIZE
	_astar.offset = CELL_SIZE * 0.5
	_astar.default_compute_heuristic = AStarGrid2D.HEURISTIC_MANHATTAN
	_astar.default_estimate_heuristic = AStarGrid2D.HEURISTIC_MANHATTAN
	_astar.diagonal_mode = AStarGrid2D.DIAGONAL_MODE_NEVER
	_astar.update()

	for i in map_size.x:
		for j in map_size.y:
			var pos = Vector2i(i, j)
			if get_cell_source_id(0, pos) == Tile.OBSTACLE:
				_astar.set_point_solid(pos)


func _draw():
	if _path.is_empty():
		return

	var last_point = _path[0]
	for index in range(1, len(_path)):
		var current_point = _path[index]
		draw_line(last_point, current_point, DRAW_COLOR, BASE_LINE_WIDTH, true)
		draw_circle(current_point, BASE_LINE_WIDTH * 2.0, DRAW_COLOR)
		last_point = current_point


func round_local_position(local_position):
	return map_to_local(local_to_map(local_position))


func is_point_walkable(local_position):
	var map_position = local_to_map(local_position)
	if _map_rect.has_point(map_position):
		return not _astar.is_point_solid(map_position)
	return false


func clear_path():
	if not _path.is_empty():
		_path.clear()
		erase_cell(0, _start_point)
		erase_cell(0, _end_point)
		# Queue redraw to clear the lines and circles.
		queue_redraw()


func find_path(local_start_point, local_end_point):
	clear_path()

	_start_point = local_to_map(local_start_point)
	_end_point = local_to_map(local_end_point)
	_path = _astar.get_point_path(_start_point, _end_point)

	if not _path.is_empty():
		set_cell(0, _start_point, Tile.START_POINT, Vector2i())
		set_cell(0, _end_point, Tile.END_POINT, Vector2i())

	# Redraw the lines and circles from the start to the end point.
	queue_redraw()

	return _path.duplicate()
