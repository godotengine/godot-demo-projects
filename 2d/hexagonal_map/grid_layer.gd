extends TileMapLayer


# Returns a global position that's the bottom corner of a tile.
# https://www.reddit.com/r/godot/comments/fuejci/having_trouble_with_snapping_to_isometric_grid/fmcl07f/
func snap_global_to_cell(world_pos: Vector2) -> Vector2:
	# map_to_local says it's the center, but it ignores texture_origin.
	return to_global(map_to_local(local_to_map(to_local(world_pos))))


func global_to_cell_pos(world_pos: Vector2) -> Vector2i:
	return local_to_map(to_local(world_pos))


func cell_to_global_pos(cell_pos: Vector2i) -> Vector2:
	return to_global(map_to_local(cell_pos))


# Change the visual appearance of tile at position world_pos. Select a TileMapLayer and
# view TileSet > Tile Sources. Use the ID field in Setup to select that tile.
func set_world_tile(world_pos: Vector2, id: int) -> void:
	var cell_space: Vector2i = global_to_cell_pos(world_pos)
	set_cell(cell_space, id)


func get_world_tile(world_pos: Vector2) -> int:
	var cell_space: Vector2i = global_to_cell_pos(world_pos)
	var id: int = get_cell_source_id(cell_space)
	return id
