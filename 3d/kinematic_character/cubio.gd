
extends KinematicBody

# Member variables
var g = -9.8
var vel = Vector3()
const MAX_SPEED = 5
const JUMP_SPEED = 7
const ACCEL= 2
const DEACCEL= 4
const MAX_SLOPE_ANGLE = 30

var dir = Vector3() # Where does the player intend to walk to

func _physics_process(delta):
	var cam_xform = $target/camera.get_global_transform()

	if Input.is_action_pressed("move_forward"):
		dir += -cam_xform.basis[2]
	if Input.is_action_pressed("move_backwards"):
		dir += cam_xform.basis[2]
	if Input.is_action_pressed("move_left"):
		dir += -cam_xform.basis[0]
	if Input.is_action_pressed("move_right"):
		dir += cam_xform.basis[0]

	dir.y = 0
	dir = dir.normalized()

	vel.y += delta * g

	var hvel = vel
	hvel.y = 0

	var target = dir * MAX_SPEED
	var accel
	if dir.dot(hvel) > 0:
		accel = ACCEL
	else:
		accel = DEACCEL

	hvel = hvel.linear_interpolate(target, accel * delta)

	vel.x = hvel.x
	vel.z = hvel.z

	vel = move_and_slide(vel, Vector3(0,1,0))

	if is_on_floor() and Input.is_action_pressed("jump"):
		vel.y = JUMP_SPEED
		
	look_system() # System to look at direction that player is moving

var new_dir:Vector3 = Vector3.ZERO
var new_angle:float = 0
func look_system():
	if (dir != Vector3.ZERO):
		new_dir = dir
	var angle:float = atan2(new_dir.x,new_dir.z) #get the angle from the player's input ie: 1,1.5,3
	new_angle = lerp_angle(new_angle,angle,.25) # smooth lerp to the new angle (using custom method to avoid weirdo rotations)
	var deg = rad2deg(new_angle) #convert the angle to degrees ie: 360,180,0,270
	rotation_degrees.y = deg #apply to kinecnatic player's rotation

func lerp_angle(from, to, weight):
	return from + short_angle_dist(from, to) * weight

func short_angle_dist(from, to):
	var max_angle = PI * 2
	var difference = fmod(to - from, max_angle)
	return fmod(2 * difference, max_angle) - difference

func _on_tcube_body_enter(body):
	if body == self:
		get_node("../ty").show()
