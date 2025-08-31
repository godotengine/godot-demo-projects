extends Node2D

const CELL_NEIGHBOR_INVALID : int = -1

@export var gridlayer : TileMapLayer
@export var move_duration : float = 0.5

var block_input := false
var current_facing_flip := false


func become_active_troll() -> void:
	# Ensure we start trolling in the middle of our grid cell.
	global_position = gridlayer.snap_global_to_cell(global_position)


# Map the input to a world-space position.
func _input_dir_to_dest(input_dir: Vector2) -> Vector2:
	var neighbor := _input_dir_to_neighbor(input_dir)
	if neighbor != CELL_NEIGHBOR_INVALID:
		# neighbor is a CellNeighbor.
		var current_cell : Vector2i = gridlayer.global_to_cell_pos(global_position)
		var cell := gridlayer.get_neighbor_cell(current_cell, neighbor)
		return gridlayer.cell_to_global_pos(cell)
	return global_position


func _matches_grid_angle(input_dir: Vector2, direction: Vector2) -> bool:
	# Divide circle of possible inputs into one segment for each side of our
	# grid shape.
	const SEGMENT := TAU/6 * 0.5
	var a : float = input_dir.angle_to(direction)
	return abs(a) < SEGMENT


func _input_dir_to_neighbor(input_dir: Vector2) -> int:
	const HEX_DELTA = TAU / 6

	# For our overhead hexmap, check the input angle against a wedge at each of
	# the 6 sides of the hex. Pick out each neighbor starting with DOWN
	# because our hexes have a flat top and bottom.
	# NOTE: For hexes with flat sides and pointy tops, we'd use a different set
	# of neighbors and use RIGHT instead of DOWN.
	var neighbors := [
		TileSet.CellNeighbor.CELL_NEIGHBOR_BOTTOM_SIDE,  # First corresponds to base Vector2.DOWN below.
		TileSet.CellNeighbor.CELL_NEIGHBOR_BOTTOM_LEFT_SIDE,
		TileSet.CellNeighbor.CELL_NEIGHBOR_TOP_LEFT_SIDE,
		TileSet.CellNeighbor.CELL_NEIGHBOR_TOP_SIDE,
		TileSet.CellNeighbor.CELL_NEIGHBOR_TOP_RIGHT_SIDE,
		TileSet.CellNeighbor.CELL_NEIGHBOR_BOTTOM_RIGHT_SIDE,
	]

	# Each neighbour specifies an additional HEX_DELTA rotation from
	# base_direction.
	for i in neighbors.size():
		if _matches_grid_angle(input_dir, Vector2.DOWN.rotated(HEX_DELTA * i)):
			return neighbors[i]

	printt("_input_dir_to_neighbor: failed to find a match.")
	return CELL_NEIGHBOR_INVALID


func _process(_dt: float) -> void:
	var motion := Input.get_vector("move_left", "move_right", "move_up", "move_down")

	# If your perspective was closer to isometric, you should rotate the input
	# to match the iso projection so you correctly interpret diagonal inputs:
	# var iso_motion := motion.rotated(TAU * 1/10)
	var iso_motion := motion
	# Use a hefty deadzone since movement is discrete.
	const DEADZONE_SQ = 0.3*0.3
	var want_movement := iso_motion.length_squared() > DEADZONE_SQ
	$DestinationPointer.visible = want_movement
	if want_movement:
		var dest : Vector2 = _input_dir_to_dest(iso_motion)
		var delta : Vector2 = dest - global_position

		$DestinationPointer.rotation = -delta.angle_to(Vector2.RIGHT)

		if block_input:
			return

		dest = gridlayer.snap_global_to_cell(dest)
		var dest_tile : int = gridlayer.get_world_tile(dest)
		var has_tile := dest_tile >= 0

		var r_dot := delta.dot(Vector2.RIGHT)
		var flip_h := r_dot <= 0
		if absf(r_dot) > 0 and flip_h != current_facing_flip:
			current_facing_flip = flip_h
			for sprite in $Visual.get_children():
				sprite.flip_h = flip_h


		block_input = true

		var tween := create_tween()
		if has_tile:
			var t := tween.tween_property(self, "global_position", delta, move_duration)
			t = t.from_current()
			t = t.as_relative()
			t = t.set_ease(Tween.EASE_IN_OUT)
			t = t.set_trans(Tween.TRANS_SINE)

		else:
			# Bounce off collision to give feedback that we recognized the input but it was invalid.
			var duration := move_duration * 0.1
			var current_pos := global_position
			var t := tween.tween_property(self, "global_position", delta * 0.1, duration)
			t = t.from_current()
			t = t.as_relative()
			t = t.set_ease(Tween.EASE_IN_OUT)
			t = t.set_trans(Tween.TRANS_SINE)
			t = tween.chain().tween_property(self, "global_position", current_pos, duration)
			t = t.from_current()
			t = t.set_ease(Tween.EASE_IN_OUT)
			t = t.set_trans(Tween.TRANS_SINE)

		await tween.finished

		block_input = false
