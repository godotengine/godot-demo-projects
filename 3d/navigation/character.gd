extends Marker3D

@export var character_speed := 10.0
@export var show_path := true

var _nav_path_line: Line3D

@onready var _nav_agent := $NavigationAgent3D as NavigationAgent3D

func _ready() -> void:
	_nav_path_line = Line3D.new()
	add_child(_nav_path_line)
	_nav_path_line.set_as_top_level(true)


func _physics_process(delta: float) -> void:
	if _nav_agent.is_navigation_finished():
		return

	var next_position := _nav_agent.get_next_path_position()
	var offset := next_position - global_position
	global_position = global_position.move_toward(next_position, delta * character_speed)

	# Make the robot look at the direction we're traveling.
	# Clamp Y to 0 so the robot only looks left and right, not up/down.
	offset.y = 0
	if not offset.is_zero_approx():
		look_at(global_position + offset, Vector3.UP)


func set_target_position(target_position: Vector3) -> void:
	_nav_agent.set_target_position(target_position)
	# Get a full navigation path with the NavigationServer API.
	if show_path:
		var start_position := global_transform.origin
		var optimize := true
		var navigation_map := get_world_3d().get_navigation_map()
		var path := NavigationServer3D.map_get_path(
				navigation_map,
				start_position,
				target_position,
				optimize
		)
		_nav_path_line.draw_path(path)
