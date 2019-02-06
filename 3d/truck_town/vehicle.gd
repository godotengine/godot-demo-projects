extends VehicleBody

# Member variables
const STEER_SPEED = 1
const STEER_LIMIT = 0.4

var steer_angle = 0
var steer_target = 0

export var engine_force_value = 40

func _physics_process(delta):
	var fwd_mps = transform.basis.xform_inv(linear_velocity).x
	
	if Input.is_action_pressed("ui_left"):
		steer_target = STEER_LIMIT
	elif Input.is_action_pressed("ui_right"):
		steer_target = -STEER_LIMIT
	else:
		steer_target = 0
	
	if Input.is_action_pressed("ui_up"):
		engine_force = engine_force_value
	else:
		engine_force = 0
	
	if Input.is_action_pressed("ui_down"):
		if (fwd_mps >= -1):
			engine_force = -engine_force_value
		else:
			brake = 1
	else:
		brake = 0.0
	
	if steer_target < steer_angle:
		steer_angle -= STEER_SPEED * delta
		if steer_target > steer_angle:
			steer_angle = steer_target
	elif steer_target > steer_angle:
		steer_angle += STEER_SPEED * delta
		if steer_target < steer_angle:
			steer_angle = steer_target
	
	steering = steer_angle
