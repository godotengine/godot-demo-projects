extends Node
# This file manages the creation and deletion of Chunks.

const CHUNK_MIDPOINT = Vector3(0.5, 0.5, 0.5) * Chunk.CHUNK_SIZE
const CHUNK_END_SIZE = Chunk.CHUNK_SIZE - 1

var render_distance: int:
	set(value):
		render_distance = value
		_delete_distance = value + 2

var _delete_distance := 0
var effective_render_distance := 0
var _old_player_chunk := Vector3i()

var _generating := true
var _deleting := false

var _chunks := {}

@onready var player: CharacterBody3D = $"../Player"

func _process(_delta: float) -> void:
	render_distance = Settings.render_distance
	var player_chunk := Vector3i((player.transform.origin / Chunk.CHUNK_SIZE).round())

	if _deleting or player_chunk != _old_player_chunk:
		_delete_far_away_chunks(player_chunk)
		_generating = true

	if not _generating:
		return

	# Try to generate chunks ahead of time based on where the player is moving.
	@warning_ignore("integer_division")
	player_chunk.y += roundi(clampf(player.velocity.y, -render_distance / 4, render_distance / 4))

	# Check existing chunks within range. If it doesn't exist, create it.
	for x in range(player_chunk.x - effective_render_distance, player_chunk.x + effective_render_distance):
		for y in range(player_chunk.y - effective_render_distance, player_chunk.y + effective_render_distance):
			for z in range(player_chunk.z - effective_render_distance, player_chunk.z + effective_render_distance):
				var chunk_position := Vector3i(x, y, z)
				if Vector3(player_chunk).distance_to(Vector3(chunk_position)) > render_distance:
					continue

				if _chunks.has(chunk_position):
					continue

				var chunk := Chunk.new()
				chunk.chunk_position = chunk_position
				_chunks[chunk_position] = chunk
				add_child(chunk)
				return

	# If we didn't generate any chunks (and therefore didn't return), what next?
	if effective_render_distance < render_distance:
		# We can move on to the next stage by increasing the effective distance.
		effective_render_distance += 1
	else:
		# Effective render distance is maxed out, done generating.
		_generating = false


func get_block_global_position(block_global_position: Vector3i) -> int:
	var chunk_position := Vector3i((block_global_position / Chunk.CHUNK_SIZE))
	if _chunks.has(chunk_position):
		var chunk: Chunk = _chunks[chunk_position]
		var sub_position := Vector3i(Vector3(block_global_position).posmod(Chunk.CHUNK_SIZE))
		if chunk.data.has(sub_position):
			return chunk.data[sub_position]

	return 0


func set_block_global_position(block_global_position: Vector3i, block_id: int) -> void:
	var chunk_position := Vector3i((Vector3(block_global_position) / Chunk.CHUNK_SIZE).floor())
	var chunk: Chunk = _chunks[chunk_position]
	var sub_position := Vector3i(Vector3(block_global_position).posmod(Chunk.CHUNK_SIZE))
	if block_id == 0:
		chunk.data.erase(sub_position)
	else:
		chunk.data[sub_position] = block_id
	chunk.regenerate()

	# We also might need to regenerate some neighboring chunks.
	if Chunk.is_block_transparent(block_id):
		if sub_position.x == 0:
			_chunks[chunk_position + Vector3i.LEFT].regenerate()
		elif sub_position.x == CHUNK_END_SIZE:
			_chunks[chunk_position + Vector3i.RIGHT].regenerate()
		if sub_position.z == 0:
			_chunks[chunk_position + Vector3i.FORWARD].regenerate()
		elif sub_position.z == CHUNK_END_SIZE:
			_chunks[chunk_position + Vector3i.BACK].regenerate()
		if sub_position.y == 0:
			_chunks[chunk_position + Vector3i.DOWN].regenerate()
		elif sub_position.y == CHUNK_END_SIZE:
			_chunks[chunk_position + Vector3i.UP].regenerate()


func clean_up() -> void:
	for chunk_position_key: Vector3i in _chunks.keys():
		var thread: Thread = _chunks[chunk_position_key]._thread
		if thread:
			thread.wait_to_finish()

	_chunks = {}
	set_process(false)

	for c in get_children():
		c.free()


func _delete_far_away_chunks(player_chunk: Vector3i) -> void:
	_old_player_chunk = player_chunk
	# If we need to delete chunks, give the new chunk system a chance to catch up.
	effective_render_distance = maxi(1, effective_render_distance - 1)

	var deleted_this_frame := 0
	# We should delete old chunks more aggressively if moving fast.
	# An easy way to calculate this is by using the effective render distance.
	# The specific values in this formula are arbitrary and from experimentation.
	var max_deletions := clampi(2 * (render_distance - effective_render_distance), 2, 8)
	# Also take the opportunity to delete far away chunks.
	for chunk_position_key: Vector3i in _chunks.keys():
		if Vector3(player_chunk).distance_to(Vector3(chunk_position_key)) > _delete_distance:
			var thread: Thread = _chunks[chunk_position_key]._thread
			if thread:
				thread.wait_to_finish()
			_chunks[chunk_position_key].queue_free()
			_chunks.erase(chunk_position_key)
			deleted_this_frame += 1
			# Limit the amount of deletions per frame to avoid lag spikes.
			if deleted_this_frame > max_deletions:
				# Continue deleting next frame.
				_deleting = true
				return

	# We're done deleting.
	_deleting = false
