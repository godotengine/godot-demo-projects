extends Node2D

enum States { IDLE, FOLLOW }

const MASS = 10.0
const ARRIVE_DISTANCE = 10.0

export(float) var speed = 200.0
var _state = null

var _path = []
var _target_point_world = Vector2()
var _target_position = Vector2()

var _velocity = Vector2()

func _ready():
	_change_state(States.IDLE)


func _process(_delta):
	if _state != States.FOLLOW:
		return
	var _arrived_to_next_point = _move_to(_target_point_world)
	if _arrived_to_next_point:
		_path.remove(0)
		if len(_path) == 0:
			_change_state(States.IDLE)
			return
		_target_point_world = _path[0]


func _unhandled_input(event):
	if event.is_action_pressed("click"):
		var global_mouse_pos = get_global_mouse_position()
		if Input.is_key_pressed(KEY_SHIFT):
			global_position = global_mouse_pos
		else:
			_target_position = global_mouse_pos
		_change_state(States.FOLLOW)


func _move_to(world_position):
	var desired_velocity = (world_position - position).normalized() * speed
	var steering = desired_velocity - _velocity
	_velocity += steering / MASS
	position += _velocity * get_process_delta_time()
	rotation = _velocity.angle()
	return position.distance_to(world_position) < ARRIVE_DISTANCE


func _change_state(new_state):
	if new_state == States.FOLLOW:
		_path = get_parent().get_node("TileMap").get_astar_path(position, _target_position)
		if not _path or len(_path) == 1:
			_change_state(States.IDLE)
			return
		# The index 0 is the starting cell.
		# We don't want the character to move back to it in this example.
		_target_point_world = _path[1]
	_state = new_state
