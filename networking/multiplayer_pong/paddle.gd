extends Area2D

export var left=false

const MOTION_SPEED=150

var motion = 0
var you_hidden = false

onready var screen_size = get_viewport_rect().size

#synchronize position and speed to the other peers
puppet func set_pos_and_motion(p_pos, p_motion):
	position = p_pos
	motion = p_motion

func _hide_you_label():
	you_hidden = true
	get_node("you").hide()

func _process(delta):
	#is the master of the paddle		
	if is_network_master():		
		motion = 0
		if Input.is_action_pressed("move_up"):
			motion -= 1
		elif Input.is_action_pressed("move_down"):
			motion += 1

		if not you_hidden and motion != 0:
			_hide_you_label()
			
		motion *= MOTION_SPEED
		
		#using unreliable to make sure position is updated as fast as possible, even if one of the calls is dropped
		rpc_unreliable("set_pos_and_motion", position, motion)
		
	else:
		if not you_hidden:
			_hide_you_label()
			
	translate( Vector2(0,motion*delta) )
	
	# set screen limits
	var pos = position
	
	if pos.y < 0:
		position = Vector2(pos.x, 0) 
	elif pos.y > screen_size.y:	
		position = Vector2(pos.x, screen_size.y)
	
	
func _on_paddle_area_enter( area ):
	if is_network_master():
		area.rpc("bounce", left, randf()) #random for new direction generated on each peer
