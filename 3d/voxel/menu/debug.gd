extends Label
# Displays some useful debug information in a Label.

@onready var player := $"../Player"
@onready var voxel_world := $"../VoxelWorld"

func _process(_delta: float) -> void:
	if Input.is_action_just_pressed(&"debug"):
		visible = not visible

	text = "Position: %.1v" % player.transform.origin \
			+ "\nEffective render distance: " + str(voxel_world.effective_render_distance) \
			+ "\nLooking: " + _cardinal_string_from_radians(player.transform.basis.get_euler().y) \
			+ "\nMemory: " + "%3.0f" % (OS.get_static_memory_usage() / 1048576.0) + " MiB" \
			+ "\nFPS: %d" % Engine.get_frames_per_second()


# Expects a rotation where 0 is North, on the range -PI to PI.
func _cardinal_string_from_radians(angle: float) -> String:
	if angle > TAU * 3 / 8:
		return "South"
	if angle < -TAU * 3 / 8:
		return "South"
	if angle > TAU * 1 / 8:
		return "West"
	if angle < -TAU * 1 / 8:
		return "East"
	return "North"
