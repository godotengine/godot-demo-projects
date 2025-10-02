class_name TerrainGenerator
extends Resource

const RANDOM_BLOCK_PROBABILITY = 0.015

static func empty() -> Dictionary[Vector3i, int]:
	return {}


static func random_blocks() -> Dictionary[Vector3i, int]:
	var random_data: Dictionary[Vector3i, int] = {}
	for x in Chunk.CHUNK_SIZE:
		for y in Chunk.CHUNK_SIZE:
			for z in Chunk.CHUNK_SIZE:
				var vec := Vector3i(x, y, z)
				if randf() < RANDOM_BLOCK_PROBABILITY:
					random_data[vec] = randi() % 29 + 1

	return random_data


static func flat(chunk_position: Vector3i) -> Dictionary[Vector3i, int]:
	var data: Dictionary[Vector3i, int] = {}

	if chunk_position.y != -1:
		return data

	for x in Chunk.CHUNK_SIZE:
		for z in Chunk.CHUNK_SIZE:
			data[Vector3i(x, 2, z)] = 3  # Grass.
			data[Vector3i(x, 1, z)] = 2  # Dirt.
			data[Vector3i(x, 0, z)] = 2  # Dirt.
			data[Vector3i(x, -1, z)] = 9  # Bedrock (can't be destroyed due to its Y coordinate).

	return data


# Used to create the project icon.
static func origin_grass(chunk_position: Vector3i) -> Dictionary[Vector3i, int]:
	if chunk_position == Vector3i.ZERO:
		return { Vector3i.ZERO: 3 }

	return {}
