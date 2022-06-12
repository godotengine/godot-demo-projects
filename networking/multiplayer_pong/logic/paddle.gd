extends Area2D

const MOTION_SPEED = 150

export var left = false

var _motion = 0
var _you_hidden = false

onready var _screen_size_y = get_viewport_rect().size.y

func _process(delta):
	# Is the master of the paddle.
	if is_network_master():
		_motion = Input.get_action_strength("move_down") - Input.get_action_strength("move_up")

		if not _you_hidden and _motion != 0:
			_hide_you_label()

		_motion *= MOTION_SPEED

		# Using unreliable to make sure position is updated as fast
		# as possible, even if one of the calls is dropped.
		rpc_unreliable("set_pos_and_motion", position, _motion)
	else:
		if not _you_hidden:
			_hide_you_label()

	translate(Vector2(0, _motion * delta))

	# Set screen limits.
	position.y = clamp(position.y, 16, _screen_size_y - 16)


# Synchronize position and speed to the other peers.
puppet func set_pos_and_motion(pos, motion):
	position = pos
	_motion = motion


func _hide_you_label():
	_you_hidden = true
	get_node("You").hide()


func _on_paddle_area_enter(area):
	if is_network_master():
		# Random for new direction generated on each peer.
		area.rpc("bounce", left, randf())
