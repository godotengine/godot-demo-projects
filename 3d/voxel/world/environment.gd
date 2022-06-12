extends WorldEnvironment
# This script controls fog based on the VoxelWorld's effective render distance.

onready var voxel_world = $"../VoxelWorld"


func _process(delta):
	environment.fog_enabled = Settings.fog_enabled
	environment.dof_blur_far_enabled = Settings.fog_enabled

	var target_distance = clamp(voxel_world.effective_render_distance, 2, voxel_world.render_distance - 1) * Chunk.CHUNK_SIZE
	var rate = delta * 4
	if environment.fog_depth_end > target_distance:
		rate *= 2
	environment.fog_depth_begin = move_toward(environment.fog_depth_begin, target_distance - Chunk.CHUNK_SIZE, rate)
	environment.fog_depth_end = move_toward(environment.fog_depth_end, target_distance, rate)
	environment.dof_blur_far_distance = environment.fog_depth_end
