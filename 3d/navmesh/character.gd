extends Spatial

const Line3D = preload("res://line3d.gd")


export(float) var character_speed = 10.0
export var show_path = true

onready var _nav_agent = $NavigationAgent
onready var _nav_path_line = $Line3D


func _ready():
	_nav_path_line.set_as_toplevel(true)


func _physics_process(delta):
	if _nav_agent.is_navigation_finished():
		return
	var next_position = _nav_agent.get_next_location()
	var offset = next_position - global_translation
	global_translation = global_translation.move_toward(next_position, delta * character_speed)

	# Make the robot look at the direction we're traveling.
	# Clamp y to 0 so the robot only looks left and right, not up/down.
	offset.y = 0
	look_at(global_translation + offset, Vector3.UP)


func set_target_location(target_location: Vector3):
	_nav_agent.set_target_location(target_location)
	# get a full navigation path with the NavigationServer API
	if show_path:
		var start_position = global_transform.origin
		var target_position = target_location
		var optimize = true
		var navigation_map = get_world().get_navigation_map()
		var path = NavigationServer.map_get_path(
				navigation_map,
				start_position,
				target_position,
				optimize)
		_nav_path_line.draw_path(path)

