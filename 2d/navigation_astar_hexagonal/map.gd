class_name Map
extends TileMap

# Private variable to not trigger on same previous paths request.
var _path_start_coords: Vector2i
var _path_end_coords: Vector2i
# Used for debug.
var _point_path = []

# In order to have cost function control.
@onready var astar_node = AStarHex2D.new()


func _ready():
	astar_node.map = self
	var walkable_cells_list = astar_add_walkable_cells()
	astar_connect_walkable_cells(walkable_cells_list)


# Need to create first astar nodes, otherwise would need to
# handle connections on not yet created nodes
# here use tilemap as source of truth (with IsObstacle and Cost custom data).
func astar_add_walkable_cells():
	var cell_array = []
	for coords in get_used_cells(0):
		# Be careful about hash collision, you could use a custom indexing function
		# depending on your needs (example coords.x + map_size.x * coords.y)
		var id = hash(coords)

		# Be carefull about what convention you used in the position parameter (here global).
		var point = to_global(map_to_local(coords))

		var tile_data: TileData = get_cell_tile_data(0, coords)

		# We could also disable point after having created it (for runtime modification for extent).
		if not tile_data or tile_data.get_custom_data("IsObstacle"):
			continue

		astar_node.add_point(id, point, tile_data.get_custom_data("Cost"))
		cell_array.append(id)

	return cell_array


# Create connections by using Tilemap get_surrounding_cells
# would work even when changing coordinate system.
func astar_connect_walkable_cells(cell_array):
	for id in cell_array:
		var point = astar_node.get_point_position(id)
		var coords = local_to_map(to_local(point))
		for neighbor_coords in get_surrounding_cells(coords):
			var neighbor_id = hash(neighbor_coords)
			if astar_node.has_point(neighbor_id):
				astar_node.connect_points(id, neighbor_id, false)


# Getter of astar result in world coordinates.
func get_astar_path(world_start, world_end):
	var path_world = []
	var start_coords = local_to_map(to_local(world_start))
	var end_coords = local_to_map(to_local(world_end))

	if _path_start_coords != start_coords or _path_end_coords != end_coords:
		_path_start_coords = start_coords
		_path_end_coords = end_coords
		for point in _recalculate_path():
			var point_world = point
			path_world.append(point_world)

	return path_world


func _recalculate_path():
	_point_path = []
	var start_point_index = hash(_path_start_coords)
	var end_point_index = hash(_path_end_coords)
	if astar_node.has_point(start_point_index) and astar_node.has_point(end_point_index):
		_point_path = astar_node.get_point_path(start_point_index, end_point_index)

	return _point_path
