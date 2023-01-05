extends Camera3D

# Higher values cause the field of view to increase more at high speeds.
const FOV_SPEED_FACTOR = 60

# Higher values cause the field of view to adapt to speed changes faster.
const FOV_SMOOTH_FACTOR = 0.2

# Don't change FOV if moving below this speed. This prevents shadows from flickering when driving slowly.
const FOV_CHANGE_MIN_SPEED = 0.05

@export var min_distance := 2.0
@export var max_distance := 4.0
@export var angle_v_adjust := 0.0
@export var height := 1.5

var base_fov := fov

# The field of view to smoothly interpolate to.
var desired_fov := fov

# Position on the last physics frame (used to measure speed).
var previous_position := global_position

func _ready():
	# This detaches the camera transform from the parent spatial node.
	set_as_top_level(true)


func _physics_process(_delta):
	var target: Vector3 = get_parent().global_transform.origin
	var pos := global_transform.origin

	var from_target := pos - target

	# Check ranges.
	if from_target.length() < min_distance:
		from_target = from_target.normalized() * min_distance
	elif from_target.length() > max_distance:
		from_target = from_target.normalized() * max_distance

	from_target.y = height

	pos = target + from_target

	look_at_from_position(pos, target, Vector3.UP)

	# Dynamic field of view based on car speed, with smoothing to prevent sudden changes on impact.
	desired_fov = clamp(base_fov + (abs(global_position.length() - previous_position.length()) - FOV_CHANGE_MIN_SPEED) * FOV_SPEED_FACTOR, base_fov, 100)
	fov = lerpf(fov, desired_fov, FOV_SMOOTH_FACTOR)

	# Turn a little up or down
	transform.basis = Basis(transform.basis[0], deg_to_rad(angle_v_adjust)) * transform.basis

	previous_position = global_position
