extends Spatial

onready var animation_tree_player = get_node("../AnimationTreePlayer");

var ROTATION_SPEED_FACTOR = 10.0;

const ANIM_FLOOR = 0
const ANIM_AIR_UP = 1
const ANIM_AIR_DOWN = 2

const SHOOT_SPEED_ANIM_FACTOR = 2.5;

var shoot_anim_time = 0;

func _ready():
	animation_tree_player.set_active(true)

func update_shoot_anim(delta, justShooted):
	if(justShooted):
		shoot_anim_time = 1.5;
	if(shoot_anim_time>0):
		shoot_anim_time -= delta*SHOOT_SPEED_ANIM_FACTOR;
		shoot_anim_time = max(shoot_anim_time, 0.0);
		var shoot_blend = min(1.0,shoot_anim_time)
		animation_tree_player.blend2_node_set_amount("gun", shoot_blend);

func update_main_anim_state(is_rising, in_on_floor):
	var anim = ANIM_FLOOR;
	if(!in_on_floor):
		anim = ANIM_AIR_UP if is_rising else ANIM_AIR_DOWN;
	animation_tree_player.transition_node_set_current("state", anim);

func update_anim_run_blend(anim_blend):
	animation_tree_player.blend2_node_set_amount("walk", anim_blend)

func update_look_dir(delta, steeringForce):
	fluent_look_at_dir(delta, steeringForce);

func fluent_look_at_dir(delta, target_dir):
	if(target_dir.length_squared()<0.1): 
		return;
	var rot_trans = transform.looking_at(target_dir,Vector3(0,1,0));
	var new_rot = Quat(transform.basis).slerp(rot_trans.basis,ROTATION_SPEED_FACTOR*delta);
	set_transform(Transform(new_rot,transform.origin));
