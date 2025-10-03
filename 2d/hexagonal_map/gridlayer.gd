extends TileMapLayer


func get_cell_half_size() -> Vector2:
	return tile_set.tile_size / 2


# Returns a global position that's the bottom corner of a tile.
# https://www.reddit.com/r/godot/comments/fuejci/having_trouble_with_snapping_to_isometric_grid/fmcl07f/
func snap_global_to_cell(world_pos: Vector2) -> Vector2:
	# map_to_local says it's the centre, but it ignores texture_origin.
	return to_global(map_to_local(local_to_map(to_local(world_pos))))


func global_to_cell_pos(world_pos: Vector2) -> Vector2i:
	return local_to_map(to_local(world_pos))


func cell_to_global_pos(cell_pos: Vector2i) -> Vector2:
	return to_global(map_to_local(cell_pos))


# Change visual appearance of tile at position v. Select a TileMapLayer and
# view TileSet > Tile Sources. Use the ID field in Setup to select that tile.
func set_world_tile(v: Vector2, id: int) -> void:
	var cell_space := global_to_cell_pos(v)
	set_cell(cell_space, id)


func get_world_tile(v: Vector2) -> int:
	var cell_space := global_to_cell_pos(v)
	var id := get_cell_source_id(cell_space)
	return id
