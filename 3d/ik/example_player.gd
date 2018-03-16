extends KinematicBody

# Walking variables.
const norm_grav = -38.8
var vel = Vector3()
const MAX_SPEED = 22
const JUMP_SPEED = 26
const ACCEL= 8.5

# A vector for storing the direction the player intends to walk towards.
var dir = Vector3()

# Sprinting variables. Similar to the varibles above, just allowing for quicker movement
const MAX_SPRINT_SPEED = 34
const SPRINT_ACCEL = 18
# A boolean to track whether or not we are sprinting
var is_sprinting = false

# How fast we slow down, and the steepest angle we can climb.
const DEACCEL= 28
const MAX_SLOPE_ANGLE = 40

# We need the camera for getting directional vectors. We rotate ourselves on the Y-axis using
# the camera_holder to avoid rotating on more than one axis at a time.
var camera
var camera_holder
# You may need to adjust depending on the sensitivity of your mouse
var MOUSE_SENSITIVITY = 0.08

# A boolean for tracking whether the jump button is down
var jump_button_down = false

# The current lean value (our position on the lean track) and the path follow node
var lean_value = 0.5
var path_follow_node = null

# A variable for tracking if the right mouse button is down.
var right_mouse_down = false
# A variable for tracking if we can fire using the left mouse button
var left_mouse_timer = 0
const LEFT_MOUSE_FIRE_TIME = 0.15
# How fast the bullets launch
const BULLET_SPEED = 100

# The animation player for aiming down the sights
var anim_player = null
# A boolean for tracking whether we can change animations or not
var anim_done = true
# The current animation name
var current_anim = "Starter"

# The end of the pistol
var pistol_end = null
# The simple bullet rigidbody
var simple_bullet = preload("res://simple_bullet.tscn")


func _ready():
	
	camera = get_node("CameraHolder/Lean_Path/PathFollow/IK_LookAt_Chest/Camera")
	camera_holder = get_node("CameraHolder")
	path_follow_node = get_node("CameraHolder/Lean_Path/PathFollow")
	
	anim_player = get_node("CameraHolder/AnimationPlayer")
	anim_player.connect("animation_finished", self, "animation_finished")
	
	pistol_end = get_node("CameraHolder/Weapon/Pistol/Pistol_end")
	
	set_physics_process(true)
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	set_process_input(true)


func _physics_process(delta):
	process_input(delta)
	process_movement(delta)


func process_input(delta):
	
	# Reset dir, so our previous movement does not effect us
	dir = Vector3()
	# Get the camera's global transform so we can use its directional vectors
	var cam_xform = camera.get_global_transform()
	
	# ----------------------------------
	# Walking
	if Input.is_key_pressed(KEY_UP) or Input.is_key_pressed(KEY_W):
		dir += -cam_xform.basis[2]
	if Input.is_key_pressed(KEY_DOWN) or Input.is_key_pressed(KEY_S):
		dir += cam_xform.basis[2]
	if Input.is_key_pressed(KEY_LEFT) or Input.is_key_pressed(KEY_A):
		dir += -cam_xform.basis[0]
	if Input.is_key_pressed(KEY_RIGHT) or Input.is_key_pressed(KEY_D):
		dir += cam_xform.basis[0]
	
	if Input.is_action_just_pressed("ui_cancel"):
		if Input.get_mouse_mode() == Input.MOUSE_MODE_VISIBLE:
			Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
		else:
			Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	
	if Input.is_mouse_button_pressed(2):
		if right_mouse_down == false:
			right_mouse_down = true
			
			if anim_done == true:
				if current_anim != "Aiming":
					anim_player.play("Aiming")
					current_anim = "Aiming"
				else:
					anim_player.play("Idle")
					current_anim = "Idle"
				
				anim_done = false
	else:
		right_mouse_down = false
	
	if Input.is_mouse_button_pressed(1):
		if left_mouse_timer <= 0:
			left_mouse_timer = LEFT_MOUSE_FIRE_TIME
			
			# Create a bullet
			var new_bullet = simple_bullet.instance()
			get_tree().root.add_child(new_bullet)
			new_bullet.global_transform = pistol_end.global_transform
			new_bullet.linear_velocity = new_bullet.global_transform.basis.z * BULLET_SPEED
	if left_mouse_timer > 0:
		left_mouse_timer -= delta
	# ----------------------------------
	
	
	# ----------------------------------
	# Sprinting
	if Input.is_key_pressed(KEY_SHIFT):
		is_sprinting = true
	else:
		is_sprinting = false
	# ----------------------------------
	
	# ----------------------------------
	# Jumping
	if Input.is_key_pressed(KEY_SPACE):
		if jump_button_down == false:
			jump_button_down = true
			if is_on_floor():
				vel.y = JUMP_SPEED
	else:
		jump_button_down = false
	# ----------------------------------
	
	
	# ----------------------------------
	# Leaninng
	if Input.is_key_pressed(KEY_Q):
		lean_value += 1.2 * delta
	elif Input.is_key_pressed(KEY_E):
		lean_value -= 1.2 * delta
	else:
		if lean_value > 0.5:
			lean_value -= 1 * delta
			if lean_value < 0.5:
				lean_value = 0.5
		elif lean_value < 0.5:
			lean_value += 1 * delta
			if lean_value > 0.5:
				lean_value = 0.5
	
	lean_value = clamp(lean_value, 0, 1)
	path_follow_node.unit_offset = lean_value
	if lean_value < 0.5:
		var lerp_value = lean_value * 2
		path_follow_node.rotation_degrees.z = (20 * (1 - lerp_value))
	else:
		var lerp_value = (lean_value - 0.5) * 2
		path_follow_node.rotation_degrees.z = (-20 * lerp_value)
	# ----------------------------------
	

func process_movement(delta):
	
	var grav = norm_grav
	
	dir.y = 0
	dir = dir.normalized()
	
	vel.y += delta*grav
	
	var hvel = vel
	hvel.y = 0
	
	var target = dir
	if is_sprinting:
		target *= MAX_SPRINT_SPEED
	else:
		target *= MAX_SPEED
	
	
	var accel
	if dir.dot(hvel) > 0:
		if is_sprinting == false:
			accel = ACCEL
		else:
			accel = SPRINT_ACCEL
	else:
		accel = DEACCEL
	
	hvel = hvel.linear_interpolate(target, accel*delta)
	
	vel.x = hvel.x
	vel.z = hvel.z
	
	vel = move_and_slide(vel,Vector3(0,1,0))


# Mouse based camera movement
func _input(event):
	
	if event is InputEventMouseMotion && Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED:
		
		rotate_y(deg2rad(event.relative.x * MOUSE_SENSITIVITY * -1))
		camera_holder.rotate_x(deg2rad(event.relative.y * MOUSE_SENSITIVITY))
		
		# We need to clamp the camera's rotation so we cannot rotate ourselves upside down
		var camera_rot = camera_holder.rotation_degrees
		if camera_rot.x < -40:
			camera_rot.x = -40
		elif camera_rot.x > 60:
			camera_rot.x = 60
		
		camera_holder.rotation_degrees = camera_rot
	
	else:
		pass


func animation_finished(anim):
	anim_done = true



