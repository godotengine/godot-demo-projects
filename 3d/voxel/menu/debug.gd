extends Label
# Displays some useful debug information in a Label.

onready var player = $"../Player"
onready var voxel_world = $"../VoxelWorld"


func _process(_delta):
	if Input.is_action_just_pressed("debug"):
		visible = !visible

	text = "Position: " + _vector_to_string_appropriate_digits(player.transform.origin)
	text += "\nEffective render distance: " + str(voxel_world.effective_render_distance)
	text += "\nLooking: " + _cardinal_string_from_radians(player.transform.basis.get_euler().y)
	text += "\nMemory: " + "%3.0f" % (OS.get_static_memory_usage() / 1048576.0) + " MiB"
	text += "\nFPS: " + str(Engine.get_frames_per_second())


# Avoids the problem of showing more digits than needed or available.
func _vector_to_string_appropriate_digits(vector):
	var factors = [1000, 1000, 1000]
	for i in range(3):
		if abs(vector[i]) > 4096:
			factors[i] = factors[i] / 10
			if abs(vector[i]) > 65536:
				factors[i] = factors[i] / 10
				if abs(vector[i]) > 524288:
					factors[i] = factors[i] / 10

	return "(" + \
			str(round(vector.x * factors[0]) / factors[0]) + ", " + \
			str(round(vector.y * factors[1]) / factors[1]) + ", " + \
			str(round(vector.z * factors[2]) / factors[2]) + ")"


# Expects a rotation where 0 is North, on the range -PI to PI.
func _cardinal_string_from_radians(angle):
	if angle > TAU * 3 / 8:
		return "South"
	if angle < -TAU * 3 / 8:
		return "South"
	if angle > TAU * 1 / 8:
		return "West"
	if angle < -TAU * 1 / 8:
		return "East"
	return "North"
