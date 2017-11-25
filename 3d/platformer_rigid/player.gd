extends RigidBody

const DECELERATION = 20.0;
const ACCELERATION = 10.0;
const MAX_SPEED = 3.1;
const JUMP_FORCE = 6.5;

onready var model = get_node("player_armature");

var ground_velocity = Vector3();

var steering_force = Vector3();
var jump_attempt = false;
var shoot_attempt = false;

var current_h_speed = 0.0;
var is_on_floor = false;
var is_rising = false;

#########
## Logic
func _process(delta):
	
	#
	processUserInput();
	if(shoot_attempt):
		shoot();
	if(jump_attempt):
		get_node("sound_jump").play()
	
	#
	model.update_look_dir(delta, steering_force);
	model.update_anim_run_blend(current_h_speed/MAX_SPEED)
	model.update_main_anim_state(is_rising, is_on_floor);
	model.update_shoot_anim(delta,shoot_attempt);

func shoot():
	var bullet = preload("res://bullet.scn").instance()
	bullet.set_transform(get_node("player_armature/Skeleton/bullet").get_global_transform().orthonormalized())
	get_parent().add_child(bullet)
	bullet.set_linear_velocity(get_node("player_armature/Skeleton/bullet").get_global_transform().basis[2].normalized()*20)
	PhysicsServer.body_add_collision_exception(bullet.get_rid(), get_rid()) # Add it to bullet
	get_node("sound_shoot").play()

#######
### Input
func processUserInput():
	var rawSteeringDir = getCurrentDirFromInput();
	var camera = get_viewport().get_camera();
	var worldDir = camera.get_transform().basis.xform(rawSteeringDir);
	worldDir.y = 0;
	steering_force = worldDir.normalized();

func getCurrentDirFromInput():
	shoot_attempt = false;
	jump_attempt = false;
	var steeringDir = Vector3();
	if(Input.is_action_pressed("move_forward")):
		steeringDir.z = -1;
	if(Input.is_action_pressed("move_backwards")):
		steeringDir.z = 1;
	if(Input.is_action_pressed("move_left")):
		steeringDir.x = -1;
	if(Input.is_action_pressed("move_right")):
		steeringDir.x = 1;
	if(Input.is_action_just_pressed("jump")):
		jump_attempt = is_on_floor;
	if(Input.is_action_just_pressed("shoot")):
		shoot_attempt = true;
	return steeringDir;

#######
## Physics
func _integrate_forces(state):
	var delta = state.get_step();
	var lv = state.get_linear_velocity() - ground_velocity;
	var velV = Vector3(0,lv.y,0);
	var velH = Vector3(lv.x, 0, lv.z);
	var hSpeed = velH.length();
	var targetDir = steering_force; 
	
	var is_user_moving = (steering_force.length_squared()>0.0);
	if(hSpeed<MAX_SPEED) && is_user_moving:
		hSpeed += ACCELERATION*delta;
		hSpeed = min(MAX_SPEED, hSpeed);
 
	if(!is_user_moving && hSpeed>0.01):
		hSpeed = hSpeed - DECELERATION*delta;
		hSpeed = max(0, hSpeed);
 
	velH = targetDir * hSpeed;
	
	if(jump_attempt):
		velV.y = JUMP_FORCE;
	
	var velocities_combined = velH +  velV;
	
	velocities_combined += get_and_update_ground_velocity(state);
	
	state.set_linear_velocity(velocities_combined);
	
	#save info about physic state of the body for 'outside' use 
	current_h_speed = hSpeed;
	is_on_floor = is_on_floor_estimate(state);
	is_rising = velV.y>0;

#this code is only for moving platforms, it reads current velocity of the floor below the player
func get_and_update_ground_velocity(state):
	var groundContact = false;
	var contactCount = state.get_contact_count();
	var i = 0;
	while(i<contactCount):
		if(state.get_contact_local_shape(i)==0): #0 is the index of ray_leg shape 
			groundContact = true;
			ground_velocity = state.get_contact_collider_velocity_at_position(i);
			ground_velocity.y=0; 
			i = contactCount;
		else:
			i += 1;
	
	if(!groundContact):
		ground_velocity = ground_velocity*0.99; #could be set to 0, but this way we can recompensate physics reading imperfections
	
	return ground_velocity

var is_on_floor_certainty = 1.0; 
func is_on_floor_estimate(state):
	var certainty_decrease_step = 0.25;
	is_on_floor_certainty -= certainty_decrease_step;
	if(is_leg_shape_colliding(state)):
		is_on_floor_certainty = 1.0; 
	return (is_on_floor_certainty>0.0);

#leg can collide only with the floor
func is_leg_shape_colliding(state):
	for i in range(state.get_contact_count()):
		if (state.get_contact_local_shape(i) == 0): 
			return true;
	return false;


