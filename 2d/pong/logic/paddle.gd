extends Area2D

const MOVE_SPEED = 100.0

var _ball_dir: int
var _up: String
var _down: String

@onready var _screen_size_y := get_viewport_rect().size.y

func _ready() -> void:
	var n := String(name).to_lower()
	_up = n + "_move_up"
	_down = n + "_move_down"
	if n == "left":
		_ball_dir = 1
	else:
		_ball_dir = -1


func _process(delta: float) -> void:
	# Move up and down based on input.
	var input := Input.get_action_strength(_down) - Input.get_action_strength(_up)
	position.y = clamp(position.y + input * MOVE_SPEED * delta, 16, _screen_size_y - 16)


func _on_area_entered(area: Area2D) -> void:
	if area.name == "Ball":
		# Assign new direction.
		area.direction = Vector2(_ball_dir, randf() * 2 - 1).normalized()
