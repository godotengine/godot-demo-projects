
extends KinematicBody2D

const MOTION_SPEED = 90.0

slave var slave_pos = Vector2()
slave var slave_motion = Vector2()

export var stunned=false

#use sync because it will be called everywhere
sync func setup_bomb(name,pos,by_who):
	var bomb = preload("res://bomb.tscn").instance()
	bomb.set_name( name ) #ensure unique name for the bomb
	bomb.set_pos( pos )	
	bomb.owner=by_who
	#no need to set network mode to bomb, will be owned by master by
	#default
	get_node("../..").add_child(bomb)
	
var current_anim=""
var prev_bombing=false
var bomb_index=0

func _fixed_process(delta):
	
	var motion = Vector2()
	
	if ( is_network_master() ):
		
		if (Input.is_action_pressed("move_left")):
			motion+=Vector2(-1, 0)
		if (Input.is_action_pressed("move_right")):
			motion+=Vector2( 1, 0)
		if (Input.is_action_pressed("move_up")):
			motion+=Vector2( 0,-1)
		if (Input.is_action_pressed("move_down")):
			motion+=Vector2( 0, 1)

		var bombing = Input.is_action_pressed("set_bomb")
		
		if (stunned):
			bombing=false
			motion=Vector2()

		if (bombing and not prev_bombing):
			var bomb_name = get_name() + str(bomb_index)
			var bomb_pos = get_pos()
			rpc("setup_bomb",bomb_name, bomb_pos, get_tree().get_network_unique_id() )
				
		prev_bombing=bombing			
		motion*=delta
		
			
		rset("slave_motion",motion)
		rset("slave_pos",get_pos())
	else:
		set_pos(slave_pos)
		motion = slave_motion
	
	var new_anim="standing"
	if (motion.y<0):
		new_anim="walk_up"
	elif (motion.y>0):
		new_anim="walk_down"
	elif (motion.x<0):
		new_anim="walk_left"
	elif (motion.x>0):
		new_anim="walk_right"
		
	if (stunned):
		new_anim="stunned"
		
	if (new_anim!=current_anim):
		current_anim=new_anim
		get_node("anim").play(current_anim)
		
	
	var remainder = move( motion * MOTION_SPEED )
	
	if (is_colliding()):
		#slide through walls
		move( get_collision_normal().slide( remainder ) )
	
	if ( not is_network_master() ):
		slave_pos = get_pos() # to avoid jitter
	
slave func stun():
	stunned=true
	
master func exploded(by_who):
	if (stunned):
		return
	stun()
	rpc("stun")
func set_player_name(name):
	get_node("Label").set_text(name)

func _ready():
	stunned=false
	slave_pos=get_pos()
	set_fixed_process(true)
	pass


