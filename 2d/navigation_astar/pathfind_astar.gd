extends TileMapLayer

# Atlas coordinates in tile set for start/end tiles.
const TILE_START_POINT = Vector2i(1, 0)
const TILE_END_POINT = Vector2i(2, 0)

const CELL_SIZE = Vector2i(64, 64)
const BASE_LINE_WIDTH: float = 3.0
const DRAW_COLOR = Color.WHITE * Color(1, 1, 1, 0.5)

# The object for pathfinding on 2D grids.
var _astar := AStarGrid2D.new()

var _start_point := Vector2i()
var _end_point := Vector2i()
var _path := PackedVector2Array()

func _ready() -> void:
	# Region should match the size of the playable area plus one (in tiles).
	# In this demo, the playable area is 17×9 tiles, so the rect size is 18×10.
	# Depending on the setup TileMapLayer's get_used_rect() can also be used.
	_astar.region = Rect2i(0, 0, 18, 10)
	_astar.cell_size = CELL_SIZE
	_astar.offset = CELL_SIZE * 0.5
	_astar.default_compute_heuristic = AStarGrid2D.HEURISTIC_MANHATTAN
	_astar.default_estimate_heuristic = AStarGrid2D.HEURISTIC_MANHATTAN
	_astar.diagonal_mode = AStarGrid2D.DIAGONAL_MODE_NEVER
	_astar.update()

	# Iterate over all cells on the tile map layer and mark them as
	# non-passable.
	for pos in get_used_cells():
		_astar.set_point_solid(pos)
		# To skip cells with certain atlas coordinates you can use:
		# if get_cell_atlas_coords(pos) == Vector2i(42, 23):
		#     ...
		# You can also add a "Custom Data Layer" to the tile set to group
		# tiles and check it here; in the following example using a string:
		# if get_cell_tile_data(pos).get_custom_data("type") == "obstacle":
		#     ...


func _draw() -> void:
	if _path.is_empty():
		return

	var last_point: Vector2 = _path[0]
	for index in range(1, len(_path)):
		var current_point: Vector2 = _path[index]
		draw_line(last_point, current_point, DRAW_COLOR, BASE_LINE_WIDTH, true)
		draw_circle(current_point, BASE_LINE_WIDTH * 2.0, DRAW_COLOR)
		last_point = current_point


func round_local_position(local_position: Vector2i) -> Vector2i:
	return map_to_local(local_to_map(local_position))


func is_point_walkable(local_position: Vector2) -> bool:
	var map_position: Vector2i = local_to_map(local_position)
	if _astar.is_in_boundsv(map_position):
		return not _astar.is_point_solid(map_position)
	return false


func clear_path() -> void:
	if not _path.is_empty():
		_path.clear()
		erase_cell(_start_point)
		erase_cell(_end_point)
		# Queue redraw to clear the lines and circles.
		queue_redraw()


func find_path(local_start_point: Vector2i, local_end_point: Vector2i) -> PackedVector2Array:
	clear_path()

	_start_point = local_to_map(local_start_point)
	_end_point = local_to_map(local_end_point)
	_path = _astar.get_point_path(_start_point, _end_point)

	if not _path.is_empty():
		set_cell(_start_point, 0, TILE_START_POINT)
		set_cell(_end_point, 0, TILE_END_POINT)

	# Redraw the lines and circles from the start to the end point.
	queue_redraw()

	return _path.duplicate()
