extends Camera

var targets = null

export (float) var MOVEMENT_SPEED = 10
export (bool) var flip_axis = false


func _ready():
	targets = get_node("targets")

func _process(delta):
	var mouse_to_world = project_local_ray_normal(get_viewport().get_mouse_position()) * MOVEMENT_SPEED
	
	if flip_axis == false:
		mouse_to_world.z *= -1
	else:
		mouse_to_world = -mouse_to_world
	
	targets.transform.origin = mouse_to_world