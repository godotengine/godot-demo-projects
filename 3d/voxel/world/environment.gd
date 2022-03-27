extends WorldEnvironment
# This script controls fog based on the VoxelWorld's effective render distance.

@onready var voxel_world = $"../VoxelWorld"


func _process(delta):
	environment.fog_enabled = Settings.fog_enabled

	var target_distance = clamp(voxel_world.effective_render_distance, 2, voxel_world.render_distance - 1) * Chunk.CHUNK_SIZE
	var rate = delta * 4
	Settings.fog_distance = move_toward(Settings.fog_distance, target_distance, rate)
	environment.fog_density = 0.5 / Settings.fog_distance
