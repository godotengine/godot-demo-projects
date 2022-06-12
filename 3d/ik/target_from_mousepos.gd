extends Camera

export(float) var MOVEMENT_SPEED = 12
export(bool) var flip_axis = false

onready var targets = $Targets


func _process(_delta):
	var mouse_to_world = project_local_ray_normal(get_viewport().get_mouse_position()) * MOVEMENT_SPEED

	if flip_axis:
		mouse_to_world = -mouse_to_world
	else:
		mouse_to_world.z *= -1

	targets.transform.origin = mouse_to_world
