extends Node2D

const CELL_NEIGHBOR_INVALID: int = -1

@export var grid: TileMapLayer
@export var move_duration: float = 0.5

var block_input: bool = false
var current_facing_flip: bool = false
var requested_iso_motion := Vector2.ZERO

@onready var destination_pointer: Node2D = $DestinationPointer


func become_active_troll() -> void:
	# Ensure we start trolling in the middle of our grid cell.
	global_position = grid.snap_global_to_cell(global_position)


# Map the input to a world-space position.
func _input_dir_to_dest(input_dir: Vector2) -> Vector2:
	var neighbor: int = _input_dir_to_neighbor(input_dir)
	if neighbor != CELL_NEIGHBOR_INVALID:
		# neighbor is a CellNeighbor.
		var current_cell: Vector2i = grid.global_to_cell_pos(global_position)
		var cell: Vector2i = grid.get_neighbor_cell(current_cell, neighbor)
		return grid.cell_to_global_pos(cell)

	return global_position


func _matches_grid_angle(input_dir: Vector2, direction: Vector2) -> bool:
	# Divide circle of possible inputs into one segment for each side of our
	# grid shape.
	const SEGMENT: float = TAU / 6.0 * 0.5
	var angle: float = input_dir.angle_to(direction)
	return abs(angle) < SEGMENT


func _input_dir_to_neighbor(input_dir: Vector2) -> int:
	const HEX_DELTA: float = TAU / 6.0

	# For our overhead hexmap, check the input angle against a wedge at each of
	# the 6 sides of the hex. Pick out each neighbor starting with DOWN
	# because our hexes have a flat top and bottom.
	# NOTE: For hexes with flat sides and pointy tops, we'd use a different set
	# of neighbors and use RIGHT instead of DOWN.
	var neighbors: Array[TileSet.CellNeighbor] = [
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

	print("_input_dir_to_neighbor: Failed to find a match.")
	return CELL_NEIGHBOR_INVALID


func _input(event: InputEvent) -> void:
	if event is InputEventMouseMotion:
		var camera = get_viewport().get_camera_2d()
		var offset: Vector2 = camera.get_global_mouse_position() - global_position
		# Ignore input on top of our troll because it makes the pointer unpredictable.
		const DEADZONE_SQ = 25.0 * 25.0
		if offset.length_squared() > DEADZONE_SQ:
			# Normalize to indicate full movement towards the mouse.
			handle_input(offset.normalized())


func _process(_dt: float) -> void:
	var motion: Vector2 = Input.get_vector(&"move_left", &"move_right", &"move_up", &"move_down")
	handle_input(motion)


func handle_input(motion: Vector2):
	# InputMap has a hefty deadzone (aiming is discrete) so can just check for zero.
	if not motion.is_zero_approx():
		# If your perspective was closer to isometric, you should rotate the input
		# to match the iso projection so you correctly interpret diagonal inputs:
		#requested_iso_motion = motion.rotated(TAU * 1.0 / 10.0)
		requested_iso_motion = motion

	var move_destination: Vector2 = _input_dir_to_dest(requested_iso_motion)
	var displacement: Vector2 = move_destination - global_position

	destination_pointer.rotation = displacement.angle()

	if block_input:
		return

	if Input.is_action_just_pressed(&"move_confirm"):
		move_destination = grid.snap_global_to_cell(move_destination)
		var destination_tile: int = grid.get_world_tile(move_destination)
		var has_tile: bool = destination_tile >= 0

		var flip_h: bool = displacement.x <= 0
		if absf(displacement.x) > 0 and flip_h != current_facing_flip:
			current_facing_flip = flip_h
			for sprite in $Visual.get_children():
				sprite.flip_h = flip_h

		block_input = true

		var tween: Tween = create_tween()
		if has_tile:
			var t: PropertyTweener = tween.tween_property(self, "global_position", displacement, move_duration)
			t = t.from_current()
			t = t.as_relative()
			t = t.set_ease(Tween.EASE_IN_OUT)
			t = t.set_trans(Tween.TRANS_SINE)

		else:
			# Bounce off collision to give feedback that we recognized the input but it was invalid.
			var duration: float = move_duration * 0.1
			var current_pos: Vector2 = global_position
			var t: PropertyTweener = tween.tween_property(self, "global_position", displacement * 0.1, duration)
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
