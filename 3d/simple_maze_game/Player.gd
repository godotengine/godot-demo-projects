extends KinematicBody

# NOTE: most of this is the same as kinematic character demo
# The biggest changes are the mouse look and updating the labels,
# other than that, everything is basically the same.

# Member variables
var grav = -9.8
var vel = Vector3()
const MAX_SPEED = 3
const JUMP_SPEED = 4
const ACCEL= 1.5
const DEACCEL= 10
const MAX_SLOPE_ANGLE = 30


var camera
var camera_holder
const MOUSE_SENSITIVITY = 0.1


# The key node and AI node are needed for the GUI
var key
var AI


var label_distance_key
var label_distance_robot


func _ready():
	camera = get_node("CameraHolder/Camera")
	camera_holder = get_node("CameraHolder")
	
	label_distance_key = get_node("GUI/LabelDistanceKey")
	label_distance_robot = get_node("GUI/LabelDistanceRobot")
	
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	set_physics_process(true)


func _physics_process(delta):
	var dir = Vector3() # Where does the player intend to walk to
	var cam_xform = camera.get_global_transform()
	
	
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
	
	dir.y = 0
	dir = dir.normalized()
	
	vel.y += delta*grav
	
	var hvel = vel
	hvel.y = 0
	
	var target = dir*MAX_SPEED
	var accel
	if dir.dot(hvel) > 0:
		accel = ACCEL
	else:
		accel = DEACCEL
	
	hvel = hvel.linear_interpolate(target, accel*delta)
	
	vel.x = hvel.x
	vel.z = hvel.z
	
	vel = move_and_slide(vel,Vector3(0,1,0))
	
	if is_on_floor() and Input.is_key_pressed(KEY_SPACE):
		vel.y = JUMP_SPEED
	
	# Update the gui
	label_distance_robot.text = str(round(self.global_transform.origin.distance_to(AI.agent.global_transform.origin)))
	label_distance_key.text = str(round(self.global_transform.origin.distance_to(key.global_transform.origin)))


# Mouse based camera movement
func _input(event):
	if event is InputEventMouseMotion && Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED:
		
		# We rotate the camera holder on one axis so the eular angles do not get messed up.
		# If we rotate the camera on both the X and Y axis, then the camera rotates strangely.
		camera_holder.rotate_y(deg2rad(event.relative.x * MOUSE_SENSITIVITY * -1))
		camera.rotate_x(deg2rad(event.relative.y * MOUSE_SENSITIVITY * -1))
		
		# We need to clamp the camera's rotation so we cannot rotate ourselves upside down
		var camera_rot = camera.get_rotation_degrees()
		if camera_rot.x < -70:
			camera_rot.x = -70
		elif camera_rot.x > 70:
			camera_rot.x = 70
		camera.set_rotation_degrees(camera_rot)
	
	else:
		pass
