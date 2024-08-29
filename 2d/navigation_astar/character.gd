extends Node2D

const PathFindAStar = preload("./pathfind_astar.gd")

enum State {
	IDLE,
	FOLLOW,
}

const MASS: float = 10.0
const ARRIVE_DISTANCE: float = 10.0

@export_range(10, 500, 0.1, "or_greater") var speed: float = 200.0

var _state := State.IDLE
var _velocity := Vector2()

var _click_position := Vector2()
var _path := PackedVector2Array()
var _next_point := Vector2()

@onready var _tile_map: PathFindAStar = $"../TileMap"

func _ready() -> void:
	_change_state(State.IDLE)


func _process(_delta: float) -> void:
	if _state != State.FOLLOW:
		return

	var arrived_to_next_point: bool = _move_to(_next_point)
	if arrived_to_next_point:
		_path.remove_at(0)
		if _path.is_empty():
			_change_state(State.IDLE)
			return
		_next_point = _path[0]


func _unhandled_input(event: InputEvent) -> void:
	_click_position = get_global_mouse_position()
	if _tile_map.is_point_walkable(_click_position):
		if event.is_action_pressed(&"teleport_to", false, true):
			_change_state(State.IDLE)
			global_position = _tile_map.round_local_position(_click_position)
		elif event.is_action_pressed(&"move_to"):
			_change_state(State.FOLLOW)


func _move_to(local_position: Vector2) -> bool:
	var desired_velocity: Vector2 = (local_position - position).normalized() * speed
	var steering: Vector2 = desired_velocity - _velocity
	_velocity += steering / MASS
	position += _velocity * get_process_delta_time()
	rotation = _velocity.angle()
	return position.distance_to(local_position) < ARRIVE_DISTANCE


func _change_state(new_state: State) -> void:
	if new_state == State.IDLE:
		_tile_map.clear_path()
	elif new_state == State.FOLLOW:
		_path = _tile_map.find_path(position, _click_position)
		if _path.size() < 2:
			_change_state(State.IDLE)
			return
		# The index 0 is the starting cell.
		# We don't want the character to move back to it in this example.
		_next_point = _path[1]
	_state = new_state
