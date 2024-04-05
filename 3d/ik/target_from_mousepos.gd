extends Camera3D

@export var MOVEMENT_SPEED: float = 12
@export var flip_axis: bool = false

@onready var targets = $Targets


func _process(_delta):
	var mouse_to_world = (
		project_local_ray_normal(get_viewport().get_mouse_position()) * MOVEMENT_SPEED
	)

	if flip_axis:
		mouse_to_world = -mouse_to_world
	else:
		mouse_to_world.z *= -1

	targets.transform.origin = mouse_to_world
