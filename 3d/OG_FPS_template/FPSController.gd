extends Spatial

class_name FPSController

# PLAYER PROPERTIES
# COLLISION PROPERTIES
export(int) var num_of_horisontal_rays = 3;
export(int) var num_of_vertical_rays = 3;
export(float) var ground_padding = 0.01;
export(float) var player_height  = 4.0;
export(float) var player_radius = 2.0;

# CAMERA PROPERTIES
export(float) var mouse_sensitivity = 1.0;

# MOVEMENT PROPERTIES
export(float) var accel_speed = 10;
export(float) var max_speed = 0.4;
export(float) var gravity = 2.0;
export(float) var gun_range = 100000;

# JUMP PROPERTIES
export(float) var jump_force = 0.65;
export(int) var max_jumps = 2;

# PLAYER VARIABLES
# INPUT
var direction_input = Vector3();

# MOVEMENT
var velocity = Vector3();

# CAMERA
var main_camera;
var mouse_delta = Vector2();

# JUMPING
var grounded = false;
var jumps_taken = 0;

# FIRING
var rate_of_fire_timer;
var firing_recovery_time = 0.8; # if we wanted to switch weapons, this value might be stored on the weapon itself
var can_fire = true;

# ANIMATION
var animator;

# ENGINE REFS
var space_state;


# Called when the node enters the scene tree for the first time.
func _ready():
	space_state = get_world().direct_space_state;
	main_camera = get_node("Camera");
	animator = get_node("Control/Hand");

	rate_of_fire_timer = get_node("RateOfFireTimer");
	rate_of_fire_timer.set_wait_time(firing_recovery_time);
	rate_of_fire_timer.one_shot = true;

	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED);


# Input, called whenever an input event is triggered
func _input(event):
	if (event is InputEventMouseMotion):
		mouse_delta = -event.relative * mouse_sensitivity;



# all movement takes place in the fixed update / physics process to avoid frame dependancies
# if you want the movement to appear smoother, my approach would be to lerp to the new location each frame based on the fixed timestep
# but only update the new location at that fixed timestep (in _physics_process)
func _physics_process(delta):
	#FIRING
	if (Input.is_action_pressed("fire") && can_fire):
		_fire();
	
	#CAMERA ROTATION
	# first need to clamp the pitch delta so we don't over rotate
	var pitch_delta = main_camera.global_transform.basis.get_euler().x - clamp(main_camera.global_transform.basis.get_euler().x + (mouse_delta.y * delta), -1.5, 1.5);
	main_camera.rotate_x(pitch_delta);
	rotate_y(mouse_delta.x * delta); # rotating the player around the y axis instead as it saves us some trouble
	mouse_delta = Vector2(0,0); # reset mouse delta after it's used, else the camera will rotate until the next mouse motion
	
	# MOVEMENT
	# adding the corrosponding direction inputs together to get a final direction input vector
	# y is zero here as we use this for horisontal movement only
	direction_input = Vector3(Input.get_action_strength("left") - Input.get_action_strength("right"), 0, Input.get_action_strength("forward") - Input.get_action_strength("back"));
	# normalise direction to ensure the player always accelerates at the same speed
	direction_input = direction_input.normalized();
	
	# seperating horisontal and vertical velocity as we want to modify them seperately
	# also means later on in the update function we can add a y component to horizontal velocity if we want to implement climbing slopes
	var horizontal_velocity = Vector3(velocity.x, 0, velocity.z);
	var vertical_velocity = Vector3(0, velocity.y, 0);
	
	# add horizontal movement onto velocity if direction is not zero, else we want to decelerate	
	if (direction_input != Vector3(0,0,0)):
		horizontal_velocity = (direction_input.x * global_transform.basis[0] + direction_input.z * global_transform.basis[2]) * accel_speed * delta;
	else:
		horizontal_velocity *= 0.5;
	
	# Clamp horizontal components of velocity to the max movespeed
	horizontal_velocity = horizontal_velocity.normalized() * min(horizontal_velocity.length(), max_speed);
	
	# COLLISIONS
	# horizontal collisons
	if (velocity != Vector3(0,0,0)):
		# calculate ray the ray starting point (bottom left of player) then work out spacing based on radius / height and num of rays
		var ray_origin = global_transform.origin - (global_transform.basis[0] * player_radius * 0.5 + Vector3(0, player_height * 0.5, 0));
		var horisontal_spacing = global_transform.basis[0] * (player_radius / num_of_horisontal_rays);
		var vertical_spacing = Vector3(0, player_height / num_of_vertical_rays, 0);
		var ray_hit_result;
		
		# cast a ray for every horisontal and vertical ray specified
		for x in num_of_horisontal_rays:
			for y in num_of_vertical_rays:
				if (y == 0):
					ray_origin.y += ground_padding; # add a little padding for rays starting at feet so player doesn't get stuck on slight edges in geometry
				ray_hit_result = space_state.intersect_ray(ray_origin, ray_origin + horizontal_velocity + player_radius * horizontal_velocity.normalized(), [self], 1 << 0);
				if (ray_hit_result):
					#if our ray hits something, move along it at a speed based on how shallow the angle is (lower speeds the closer the player is to perpendicular to the wall) 
					var wall_direction = ray_hit_result.normal.cross(-Vector3.UP);
					var angle = rad2deg(ray_hit_result.normal.angle_to(-horizontal_velocity.normalized()))
					
					if (horizontal_velocity.x * -ray_hit_result.normal.z > horizontal_velocity.z * -ray_hit_result.normal.x):
						wall_direction *= -1;
					
					var velocity_modifier = angle / 90;
					horizontal_velocity.x = wall_direction.x * accel_speed * delta * velocity_modifier;
					horizontal_velocity.z = wall_direction.z * accel_speed * delta * velocity_modifier;
				ray_origin += vertical_spacing;
			ray_origin.y = global_transform.origin.y - player_height * 0.5;
			ray_origin += horisontal_spacing;
	
	# vertical collisions
	# only need to cast one ray down this time
	var ray_hit_result = space_state.intersect_ray(global_transform.origin, global_transform.origin + Vector3.DOWN * player_height * 0.5);
	if (ray_hit_result):
		vertical_velocity.y = 0;
		# if the ray hit, set the players position to half their height where they hit the ground, stops them sinking into the floor
		set_translation(Vector3(get_translation().x, ray_hit_result.position.y + player_height * 0.45, get_translation().z));
		#reset jumps taken on land
		jumps_taken = 0;
	else:
		grounded = false;
		vertical_velocity.y -= gravity * delta;
	
	# JUMPING
	# needs to be checked after collisions
	if (Input.is_action_just_pressed("jump") && (grounded || jumps_taken < max_jumps)):
		vertical_velocity.y = jump_force;
		jumps_taken += 1;
	
	velocity = horizontal_velocity + vertical_velocity;
	
	# FINAL TRANSLATION
	set_translation(get_translation() + velocity);

func _fire():
	can_fire = false;
	rate_of_fire_timer.start();
	animator.set_animation_state(animator.ANIMATION_STATES.FIRING);
	# cast ray from center of camera location to a point as far as the range on our weapon
	var ray_hit_result = space_state.intersect_ray(main_camera.global_transform.origin, main_camera.global_transform.origin + gun_range * main_camera.global_transform.basis[2] * -1, [self])
	if (ray_hit_result):
		var root = ray_hit_result.collider;
		# iterate up the tree until we find something that has the FPSEnemy script attatched or until there are no more parents to get
		while(true):
			if (root.script == FPSEnemy):
				root.take_damage(10, global_transform.origin - root.global_transform.origin, 100);
				return;
			if (!root.get_parent()):
				return;
			root = root.get_parent();


# rate of fire timer listener
func _on_RateOfFireTimer_timeout():
	can_fire = true;
