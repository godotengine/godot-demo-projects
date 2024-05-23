class_name Chunk
extends StaticBody3D
# These chunks are instanced and given data by VoxelWorld.
# After that, chunks finish setting themselves up in the _ready() function.
# If a chunk is changed, its "regenerate" method is called.

const CHUNK_SIZE = 16 # Keep in sync with TerrainGenerator.
const TEXTURE_SHEET_WIDTH = 8

const CHUNK_LAST_INDEX = CHUNK_SIZE - 1
const TEXTURE_TILE_SIZE = 1.0 / TEXTURE_SHEET_WIDTH

var data := {}
var chunk_position := Vector3i()

var _thread: Thread

@onready var voxel_world := get_parent()

func _ready() -> void:
	transform.origin = Vector3(chunk_position * CHUNK_SIZE)
	name = str(chunk_position)
	if Settings.world_type == 0:
		data = TerrainGenerator.random_blocks()
	else:
		data = TerrainGenerator.flat(chunk_position)

	# We can only add colliders in the main thread due to physics limitations.
	_generate_chunk_collider()
	# However, we can use a thread for mesh generation.
	_thread = Thread.new()
	_thread.start(_generate_chunk_mesh)


func regenerate() -> void:
	# Clear out all old nodes first.
	for c in get_children():
		remove_child(c)
		c.queue_free()

	# Then generate new ones.
	_generate_chunk_collider()
	_generate_chunk_mesh()


func _generate_chunk_collider() -> void:
	if data.is_empty():
		# Avoid errors caused by StaticBody3D not having colliders.
		_create_block_collider(Vector3.ZERO)
		collision_layer = 0
		collision_mask = 0
		return

	# For each block, generate a collider. Ensure collision layers are enabled.
	collision_layer = 0xFFFFF
	collision_mask = 0xFFFFF
	for block_position: Vector3i in data.keys():
		var block_id: int = data[block_position]
		if block_id != 27 and block_id != 28:
			_create_block_collider(block_position)


func _generate_chunk_mesh() -> void:
	if data.is_empty():
		return

	var surface_tool := SurfaceTool.new()
	surface_tool.begin(Mesh.PRIMITIVE_TRIANGLES)

	# For each block, add data to the SurfaceTool and generate a collider.
	for block_position: Vector3i in data.keys():
		var block_id: int = data[block_position]
		_draw_block_mesh(surface_tool, block_position, block_id)

	# Create the chunk's mesh from the SurfaceTool data.
	surface_tool.generate_normals()
	surface_tool.generate_tangents()
	surface_tool.index()
	var array_mesh := surface_tool.commit()
	var mi := MeshInstance3D.new()
	mi.mesh = array_mesh
	mi.material_override = preload("res://world/textures/material.tres")
	add_child.call_deferred(mi)


func _draw_block_mesh(surface_tool: SurfaceTool, block_sub_position: Vector3i, block_id: int) -> void:
	var verts := Chunk.calculate_block_verts(block_sub_position)
	var uvs := Chunk.calculate_block_uvs(block_id)
	var top_uvs := uvs
	var bottom_uvs := uvs

	# Bush blocks get drawn in their own special way.
	if block_id == 27 or block_id == 28:
		_draw_block_face(surface_tool, [verts[2], verts[0], verts[7], verts[5]], uvs)
		_draw_block_face(surface_tool, [verts[7], verts[5], verts[2], verts[0]], uvs)
		_draw_block_face(surface_tool, [verts[3], verts[1], verts[6], verts[4]], uvs)
		_draw_block_face(surface_tool, [verts[6], verts[4], verts[3], verts[1]], uvs)
		return

	# Allow some blocks to have different top/bottom textures.
	if block_id == 3: # Grass.
		top_uvs = Chunk.calculate_block_uvs(0)
		bottom_uvs = Chunk.calculate_block_uvs(2)
	elif block_id == 5: # Furnace.
		top_uvs = Chunk.calculate_block_uvs(31)
		bottom_uvs = top_uvs
	elif block_id == 12: # Log.
		top_uvs = Chunk.calculate_block_uvs(30)
		bottom_uvs = top_uvs
	elif block_id == 19: # Bookshelf.
		top_uvs = Chunk.calculate_block_uvs(4)
		bottom_uvs = top_uvs

	# Main rendering code for normal blocks.
	var other_block_position := block_sub_position + Vector3i.LEFT
	var other_block_id := 0
	if other_block_position.x == -1:
		other_block_id = voxel_world.get_block_global_position(other_block_position + chunk_position * CHUNK_SIZE)
	elif data.has(other_block_position):
		other_block_id = data[other_block_position]
	if block_id != other_block_id and Chunk.is_block_transparent(other_block_id):
		_draw_block_face(surface_tool, [verts[2], verts[0], verts[3], verts[1]], uvs)

	other_block_position = block_sub_position + Vector3i.RIGHT
	other_block_id = 0
	if other_block_position.x == CHUNK_SIZE:
		other_block_id = voxel_world.get_block_global_position(other_block_position + chunk_position * CHUNK_SIZE)
	elif data.has(other_block_position):
		other_block_id = data[other_block_position]
	if block_id != other_block_id and Chunk.is_block_transparent(other_block_id):
		_draw_block_face(surface_tool, [verts[7], verts[5], verts[6], verts[4]], uvs)

	other_block_position = block_sub_position + Vector3i.FORWARD
	other_block_id = 0
	if other_block_position.z == -1:
		other_block_id = voxel_world.get_block_global_position(other_block_position + chunk_position * CHUNK_SIZE)
	elif data.has(other_block_position):
		other_block_id = data[other_block_position]
	if block_id != other_block_id and Chunk.is_block_transparent(other_block_id):
		_draw_block_face(surface_tool, [verts[6], verts[4], verts[2], verts[0]], uvs)

	other_block_position = block_sub_position + Vector3i.BACK
	other_block_id = 0
	if other_block_position.z == CHUNK_SIZE:
		other_block_id = voxel_world.get_block_global_position(other_block_position + chunk_position * CHUNK_SIZE)
	elif data.has(other_block_position):
		other_block_id = data[other_block_position]
	if block_id != other_block_id and Chunk.is_block_transparent(other_block_id):
		_draw_block_face(surface_tool, [verts[3], verts[1], verts[7], verts[5]], uvs)

	other_block_position = block_sub_position + Vector3i.DOWN
	other_block_id = 0
	if other_block_position.y == -1:
		other_block_id = voxel_world.get_block_global_position(other_block_position + chunk_position * CHUNK_SIZE)
	elif data.has(other_block_position):
		other_block_id = data[other_block_position]
	if block_id != other_block_id and Chunk.is_block_transparent(other_block_id):
		_draw_block_face(surface_tool, [verts[4], verts[5], verts[0], verts[1]], bottom_uvs)

	other_block_position = block_sub_position + Vector3i.UP
	other_block_id = 0
	if other_block_position.y == CHUNK_SIZE:
		other_block_id = voxel_world.get_block_global_position(other_block_position + chunk_position * CHUNK_SIZE)
	elif data.has(other_block_position):
		other_block_id = data[other_block_position]
	if block_id != other_block_id and Chunk.is_block_transparent(other_block_id):
		_draw_block_face(surface_tool, [verts[2], verts[3], verts[6], verts[7]], top_uvs)


func _draw_block_face(surface_tool: SurfaceTool, verts: Array[Vector3], uvs: Array[Vector2]) -> void:
	surface_tool.set_uv(uvs[1]); surface_tool.add_vertex(verts[1])
	surface_tool.set_uv(uvs[2]); surface_tool.add_vertex(verts[2])
	surface_tool.set_uv(uvs[3]); surface_tool.add_vertex(verts[3])

	surface_tool.set_uv(uvs[2]); surface_tool.add_vertex(verts[2])
	surface_tool.set_uv(uvs[1]); surface_tool.add_vertex(verts[1])
	surface_tool.set_uv(uvs[0]); surface_tool.add_vertex(verts[0])


func _create_block_collider(block_sub_position: Vector3) -> void:
	var collider := CollisionShape3D.new()
	collider.shape = BoxShape3D.new()
	collider.shape.extents = Vector3.ONE / 2
	collider.transform.origin = Vector3(block_sub_position) + Vector3.ONE / 2
	add_child(collider)


static func calculate_block_uvs(block_id: int) -> Array[Vector2]:
	# This method only supports square texture sheets.
	@warning_ignore("integer_division")
	var row := block_id / TEXTURE_SHEET_WIDTH
	var col := block_id % TEXTURE_SHEET_WIDTH

	return [
		# Godot 4 has a weird bug where there are seams at the edge
		# of the textures. Adding a margin of 0.01 "fixes" it.
		TEXTURE_TILE_SIZE * Vector2(col + 0.01, row + 0.01),
		TEXTURE_TILE_SIZE * Vector2(col + 0.01, row + 0.99),
		TEXTURE_TILE_SIZE * Vector2(col + 0.99, row + 0.01),
		TEXTURE_TILE_SIZE * Vector2(col + 0.99, row + 0.99),
	]


static func calculate_block_verts(block_position: Vector3) -> Array[Vector3]:
	return [
		Vector3(block_position.x, block_position.y, block_position.z),
		Vector3(block_position.x, block_position.y, block_position.z + 1),
		Vector3(block_position.x, block_position.y + 1, block_position.z),
		Vector3(block_position.x, block_position.y + 1, block_position.z + 1),
		Vector3(block_position.x + 1, block_position.y, block_position.z),
		Vector3(block_position.x + 1, block_position.y, block_position.z + 1),
		Vector3(block_position.x + 1, block_position.y + 1, block_position.z),
		Vector3(block_position.x + 1, block_position.y + 1, block_position.z + 1),
	]


static func is_block_transparent(block_id: int) -> int:
	return block_id == 0 or (block_id > 25 and block_id < 30)
