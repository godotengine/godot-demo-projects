
extends KinematicBody2D


const GRAVITY_VEC = Vector2(0,900)
const FLOOR_NORMAL = Vector2(1,-1)

const WALK_SPEED = 70
const STATE_WALKING = 0
const STATE_KILLED = 1

var linear_velocity = Vector2()
var direction = -1
var anim=""

var state = STATE_WALKING

onready var detect_floor_left = get_node("detect_floor_left")
onready var detect_wall_left = get_node("detect_wall_left")
onready var detect_floor_right = get_node("detect_floor_right")
onready var detect_wall_right = get_node("detect_wall_right")
onready var sprite = get_node("sprite")

func _fixed_process(delta):
	
	var new_anim="idle"
	
	if (state==STATE_WALKING):
	
		linear_velocity+= GRAVITY_VEC*delta
		linear_velocity.x = direction * WALK_SPEED
		linear_velocity = move_and_slide( linear_velocity, FLOOR_NORMAL )
		
		if (not detect_floor_left.is_colliding() or detect_wall_left.is_colliding()):
			direction=1.0
			
		if (not detect_floor_right.is_colliding() or detect_wall_right.is_colliding()):
			direction=-1.0
		
		sprite.set_scale( Vector2(direction,1.0) )
		
		new_anim="walk"
	else:
		new_anim="explode"
		
	if (anim!=new_anim):
		anim=new_anim
		get_node("anim").play(anim)
			
		
		
func hit_by_bullet():
	state=STATE_KILLED	

func _ready():
	set_fixed_process(true)


