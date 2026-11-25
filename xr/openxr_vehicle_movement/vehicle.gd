extends VehicleBody3D

const MAX_STEERING_ANGLE : float = deg_to_rad(20)
const FORWARD_ACCELERATION : float = 75.0
const BACKWARD_ACCELERATION : float = 40.0
const BRAKE_FORCE : float = 2.0
const MIN_VELOCITY : float = 1.0
const MAX_CAMERA_DISTANCE : float = 0.3
const CAMERA_FADE : float = 0.1

var use_xr_input = false
var xr_steer_with_left = false
var xr_steer_with_right = false
var reverse = false

# Called when the node enters the scene tree for the first time.
func _ready():
	var material : ShaderMaterial = %SteeringWheelDisplay.material_override
	if material:
		material.set_shader_parameter("albedo_texture", %InfoViewport.get_texture())

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	# Check steering
	var steering_input : float  = 0.0
	if use_xr_input:
		var direction : Vector2 = Vector2()
		var to_local : Transform3D = $SteeringWheelAnchor.global_transform.inverse()

		if %RightHand.get_has_tracking_data() and xr_steer_with_right:
			var hand_pos : Vector3 = to_local * %RightHand.global_transform.origin
			direction = Vector2(hand_pos.x, hand_pos.y)

		if %LeftHand.get_has_tracking_data() and xr_steer_with_left:
			var hand_pos : Vector3 = to_local * %LeftHand.global_transform.origin
			direction -= Vector2(hand_pos.x, hand_pos.y)

		direction = direction.normalized()

		# Calculate our new steering input
		steering_input = -direction.angle_to(Vector2(0.0, -1.0))
		if steering_input > PI:
			steering_input -= 2.0 * PI
		elif steering_input < -PI:
			steering_input += 2.0 * PI
		steering_input /= PI

		# Add protection against complete 180 flip
		var was_steering_input : float = steering / -MAX_STEERING_ANGLE
		if was_steering_input < -0.75 and steering_input > 0.75:
			steering_input = -1.0
		elif was_steering_input > 0.75 and steering_input < -0.75:
			steering_input = 1.0
	else:
		steering_input = Input.get_axis("turn_left", "turn_right")
	steering = steering_input * -MAX_STEERING_ANGLE

	%SteeringWheelPivot.rotation.z = steering * (deg_to_rad(180) / -MAX_STEERING_ANGLE)

	# Check
	var accel_input : float = 0.0
	var brake_input : float = 0.0
	var just_pressed_accel : bool = false
	var just_pressed_brake : bool = false
	if use_xr_input:
		# Remember our current values
		var was_accel_input = accel_input
		var was_brake_input = brake_input

		# Get our new values.
		# In XR we have bound these to either left or right hand.
		# We don't have an API yet to gather the action value regardless of what its bound to.
		accel_input = %LeftHand.get_float("accelerate") + %RightHand.get_float("accelerate")
		brake_input = %LeftHand.get_float("brake") + %RightHand.get_float("brake")

		just_pressed_accel = accel_input > 0.0 and was_accel_input == 0.0
		just_pressed_brake = brake_input > 0.0 and was_brake_input == 0.0
	else:
		accel_input = Input.get_action_strength("accelerate")
		brake_input = Input.get_action_strength("brake")
		just_pressed_accel = Input.is_action_just_pressed("accelerate")
		just_pressed_brake = Input.is_action_just_pressed("brake")

	var auto_brake_force : float = 0.0
	if linear_velocity.length() < MIN_VELOCITY:
		auto_brake_force = 0.1
		if just_pressed_brake:
			reverse = true
		elif just_pressed_accel:
			reverse = false

	if !reverse:
		engine_force = accel_input * FORWARD_ACCELERATION
		brake = auto_brake_force + brake_input * BRAKE_FORCE
	else:
		engine_force = brake_input * -BACKWARD_ACCELERATION
		brake = auto_brake_force + accel_input * BRAKE_FORCE

	# Blackout screen if our head moves too far away
	var camera_distance_from_origin = %XRCamera3D.position.length()
	%BlackOut.fade = clamp((camera_distance_from_origin - MAX_CAMERA_DISTANCE) / CAMERA_FADE, 0.0, 1.0)

	# Update some info:
	var velocity = linear_velocity.length()
	%InfoUI.set_velocity(velocity)


func _on_hand_detector_body_entered(body):
	var hand : XRHand3D = body.get_parent()
	if hand:
		hand.set_hand_mesh_toplevel(true)

		if hand.tracker == "left_hand":
			%LeftHandAnchor.remote_path = hand.get_hand_mesh_path()
			xr_steer_with_left = true
		elif hand.tracker == "right_hand":
			%RightHandAnchor.remote_path = hand.get_hand_mesh_path()
			xr_steer_with_right = true

	use_xr_input = xr_steer_with_left or xr_steer_with_right


func _on_hand_detector_body_exited(body):
	var hand : XRHand3D = body.get_parent()
	if hand:
		if hand.tracker == "left_hand":
			%LeftHandAnchor.remote_path = NodePath()
			xr_steer_with_left = false
		elif hand.tracker == "right_hand":
			%RightHandAnchor.remote_path = NodePath()
			xr_steer_with_right = false

		hand.set_hand_mesh_toplevel(false)

	use_xr_input = xr_steer_with_left or xr_steer_with_right
