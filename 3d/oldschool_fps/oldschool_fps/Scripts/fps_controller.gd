class_name FPSController
extends Spatial
# Uses raycasted solution for old school collisions.


const RADIAN_RIGHT_ANGLE = 1.5708
const CAMERA_MAX_PITCH = 1.5

export(int) var num_of_horisontal_rays = 3
export(int) var num_of_vertical_rays = 3
export(float) var ground_padding = 0.2
export(float) var player_height  = 4.0
export(float) var player_radius = 1.5

export(float) var mouse_sensitivity = 0.5


export(float) var accel_speed = 20
export(float) var decel_multiplier = 0.5
export(float) var max_speed = 0.5
export(float) var gravity = 1.0
export(float) var gun_range = 100000


export(float) var jump_force = 0.3
export(int) var max_jumps = 2

var direction_input = Vector3()

var velocity = Vector3()
var old_position
var new_position

var main_camera
var mouse_delta
var camera_rotation_delta

var grounded = false
var jumps_taken = 0

var rate_of_fire_timer
var firing_recovery_time = 0.65 # if we wanted to switch weapons, this value might be stored on the weapon type itself
var can_fire = true

var animator

var player_half_height = player_height * 0.5
var player_half_radius = player_radius * 0.5

var time_since_last_physics_process = 0

var space_state


# Called when the node enters the scene tree for the first time.
func _ready():
	space_state = get_world().direct_space_state
	main_camera = get_node("Camera")
	animator = get_node("Control/Hand")

	rate_of_fire_timer = get_node("RateOfFireTimer")
	rate_of_fire_timer.set_wait_time(firing_recovery_time)
	rate_of_fire_timer.one_shot = true
	
	new_position = get_translation()
	old_position = new_position
	
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	mouse_delta = Vector2(0, 0) 


# Input, called whenever an input event is triggered
func _input(event):
	if event is InputEventMouseMotion:
		mouse_delta = -event.relative * mouse_sensitivity


# Position and rotation are updated here, but not applied to the character yet
func _physics_process(delta):
	if Input.is_action_pressed("fire") and can_fire:
		fire()

	# clamp the pitch delta so we don't over rotate, x rotation appied to camera, y rotation applied to self
	var pitch_delta = main_camera.global_transform.basis.get_euler().x - clamp(main_camera.global_transform.basis.get_euler().x + (mouse_delta.y * delta), -CAMERA_MAX_PITCH, CAMERA_MAX_PITCH)
	camera_rotation_delta = Vector2(pitch_delta, mouse_delta.x * delta)
	mouse_delta = Vector2(0,0) # reset mouse delta after we're done with it, doesn't get reset if there is no mouse input

	direction_input = Vector3(Input.get_action_strength("left") - Input.get_action_strength("right"), 0, 
			Input.get_action_strength("forward") - Input.get_action_strength("back"))
	direction_input = direction_input.normalized()
	
	# seperating horizontal and vertical velocity as we want to modify them seperately
	# POTENTIAL EXPANSION: later in the update function we can add a y component to horizontal velocity if we want to implement climbing slopes
	var horizontal_velocity = Vector3(velocity.x, 0, velocity.z)
	var vertical_velocity = Vector3(0, velocity.y, 0)
	
	if direction_input != Vector3(0, 0, 0):
		horizontal_velocity = (direction_input.x * global_transform.basis[0] + 
				direction_input.z * global_transform.basis[2]) * accel_speed * delta
	else:
		horizontal_velocity *= decel_multiplier
	
	horizontal_velocity = clamp_vector_magnitude(horizontal_velocity, max_speed)
	
	# horizontal collisons, calculate the ray starting point (bottom left of player) then work out spacing based on radius / height and num of rays
	if velocity != Vector3(0, 0, 0):
		var ray_origin = global_transform.origin - (global_transform.basis[0] * player_half_radius + 
				Vector3(0, player_half_height - ground_padding, 0))

		var horizontal_spacing = global_transform.basis[0] * (player_radius / num_of_horisontal_rays)
		var vertical_spacing = Vector3(0, player_height / num_of_vertical_rays, 0)
		
		# if our ray hits something, move along it at a speed based on how shallow the angle is (lower speeds the closer the player is to perpendicular to the wall) 
		for x in num_of_horisontal_rays:
			for y in num_of_vertical_rays:
				var ray_hit_result = space_state.intersect_ray(ray_origin, 
						ray_origin + horizontal_velocity + player_radius * horizontal_velocity.normalized())
				
				if ray_hit_result:
					var wall_direction = ray_hit_result.normal.cross(-Vector3.UP)
					var angle = ray_hit_result.normal.angle_to(-horizontal_velocity.normalized())
										
					if horizontal_velocity.x * -ray_hit_result.normal.z > horizontal_velocity.z * -ray_hit_result.normal.x:
						wall_direction *= -1
					
					var velocity_modifier = angle / RADIAN_RIGHT_ANGLE
					horizontal_velocity = wall_direction * accel_speed * delta * velocity_modifier
					
				ray_origin += vertical_spacing
				
			ray_origin.y = (global_transform.origin.y - player_half_height) + ground_padding
			ray_origin += horizontal_spacing
	
	# vertical collisions, could use this ray info for slope detection
	var ray_hit_result = space_state.intersect_ray(global_transform.origin, 
			global_transform.origin + Vector3.DOWN * player_half_height)

	if ray_hit_result:
		vertical_velocity.y = 0
		# stop them sinking into the floor ever
		set_translation(Vector3(get_translation().x, 
				ray_hit_result.position.y + player_half_height, get_translation().z))
		
		jumps_taken = 0
	else:
		# collision checks above player if the player is in the air
		ray_hit_result = space_state.intersect_ray(global_transform.origin, 
				global_transform.origin + Vector3.UP * player_half_height)
		if (ray_hit_result):
			vertical_velocity.y  = 0
			# stop them sticking to the ceiling
			set_translation(Vector3(get_translation().x, 
					ray_hit_result.position.y - player_half_height, get_translation().z))
		grounded = false
		vertical_velocity.y -= gravity * delta
	
	if Input.is_action_just_pressed("jump") and (grounded or jumps_taken < max_jumps):
		vertical_velocity.y = jump_force
		jumps_taken += 1
	
	velocity = horizontal_velocity + vertical_velocity
	
	old_position = get_translation()
	new_position = old_position + velocity
	
	time_since_last_physics_process = 0


# only smoothing here, no physics, applying position and rotation
func _process(delta):
	# lerp position calculated in _physics_process
	time_since_last_physics_process += delta
	var percent_til_next_physics_process = time_since_last_physics_process / get_physics_process_delta_time()
	var position = old_position + (new_position - old_position) * percent_til_next_physics_process
	set_translation(position)
	
	# lerp camera rotation
	main_camera.rotate_x(camera_rotation_delta.x * percent_til_next_physics_process)
	rotate_y(camera_rotation_delta.y * percent_til_next_physics_process)


# cast ray from center of camera location to a point in the cameras forward based on range (iterates up the tree to find enemy)
func fire():
	can_fire = false
	rate_of_fire_timer.start()
	animator.set_animation_state(animator.ANIMATION_STATES.FIRING)
	
	var ray_hit_result = space_state.intersect_ray(main_camera.global_transform.origin,
			 main_camera.global_transform.origin + gun_range * main_camera.global_transform.basis[2] * -1)
	if ray_hit_result:
		var root = ray_hit_result.collider
		
		while true:
			if root.script == FPSEnemy:
				root.take_damage(10, global_transform.origin - root.global_transform.origin, 100)
				return
			if !root.get_parent():
				return
			root = root.get_parent()


func clamp_vector_magnitude(var vector, var max_length):
	return vector.normalized() * min(vector.length(), max_length)


# rate of fire timer listener
func _on_RateOfFireTimer_timeout():
	can_fire = true
