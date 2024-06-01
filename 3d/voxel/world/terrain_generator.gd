class_name TerrainGenerator
extends Resource

const RANDOM_BLOCK_PROBABILITY = 0.015

static func empty() -> Dictionary:
	return {}


static func random_blocks() -> Dictionary:
	var random_data := {}
	for x in Chunk.CHUNK_SIZE:
		for y in Chunk.CHUNK_SIZE:
			for z in Chunk.CHUNK_SIZE:
				var vec := Vector3i(x, y, z)
				if randf() < RANDOM_BLOCK_PROBABILITY:
					random_data[vec] = randi() % 29 + 1

	return random_data


static func flat(chunk_position: Vector3i) -> Dictionary:
	var data := {}

	if chunk_position.y != -1:
		return data

	for x in Chunk.CHUNK_SIZE:
		for z in Chunk.CHUNK_SIZE:
			data[Vector3i(x, 0, z)] = 3

	return data


# Used to create the project icon.
static func origin_grass(chunk_position: Vector3i) -> Dictionary:
	if chunk_position == Vector3i.ZERO:
		return { Vector3i.ZERO: 3 }

	return {}
