extends Area2D

const MOTION_SPEED = 150

@export var left := false

var _motion := 0.0
var _you_hidden := false

@onready var _screen_size_y := get_viewport_rect().size.y

func _process(delta: float) -> void:
	# Is the master of the paddle.
	if is_multiplayer_authority():
		_motion = Input.get_axis(&"move_up", &"move_down")

		if not _you_hidden and _motion != 0:
			_hide_you_label()

		_motion *= MOTION_SPEED

		# Using unreliable to make sure position is updated as fast
		# as possible, even if one of the calls is dropped.
		set_pos_and_motion.rpc(position, _motion)
	else:
		if not _you_hidden:
			_hide_you_label()

	translate(Vector2(0.0, _motion * delta))

	# Set screen limits.
	position.y = clampf(position.y, 16, _screen_size_y - 16)


# Synchronize position and speed to the other peers.
@rpc("unreliable")
func set_pos_and_motion(pos: Vector2, motion: float) -> void:
	position = pos
	_motion = motion


func _hide_you_label() -> void:
	_you_hidden = true
	$You.hide()


func _on_paddle_area_enter(area: Area2D) -> void:
	if is_multiplayer_authority():
		# Random for new direction generated checked each peer.
		area.bounce.rpc(left, randf())
