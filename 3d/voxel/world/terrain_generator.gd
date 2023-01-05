class_name TerrainGenerator
extends Resource

# Can't be "Chunk.CHUNK_SIZE" due to cyclic dependency issues.
# https://github.com/godotengine/godot/issues/21461
const CHUNK_SIZE = 16

const RANDOM_BLOCK_PROBABILITY = 0.015


static func empty():
	return {}


static func random_blocks():
	var random_data = {}
	for x in range(CHUNK_SIZE):
		for y in range(CHUNK_SIZE):
			for z in range(CHUNK_SIZE):
				var vec = Vector3i(x, y, z)
				if randf() < RANDOM_BLOCK_PROBABILITY:
					random_data[vec] = randi() % 29 + 1
	return random_data


static func flat(chunk_position):
	var data = {}

	if chunk_position.y != -1:
		return data

	for x in range(CHUNK_SIZE):
		for z in range(CHUNK_SIZE):
			data[Vector3i(x, 0, z)] = 3

	return data


# Used to create the project icon.
static func origin_grass(chunk_position):
	if chunk_position == Vector3i.ZERO:
		return {Vector3i.ZERO: 3}

	return {}
