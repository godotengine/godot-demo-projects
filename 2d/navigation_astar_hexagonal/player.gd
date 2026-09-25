extends CharacterBody2D

@export var map: Map
@export var speed = 400  # Move speed in pixels/sec.

var _path_to_target: Array
var _target = null


func _input(event):
	if event.is_action_pressed(&"click"):
		_path_to_target = map.get_astar_path(global_position, get_global_mouse_position())
		if not _path_to_target.is_empty():
			global_position = _path_to_target.pop_front()
			_target = null


func _physics_process(_delta):
	if _target and position.distance_to(_target) > 10.0:
		velocity = position.direction_to(_target) * speed
	elif not _path_to_target.is_empty():
		_target = _path_to_target.pop_front()
	else:
		_target = null
		velocity = Vector2.ZERO

	move_and_slide()
