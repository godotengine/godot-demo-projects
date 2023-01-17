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

var camera_type := CameraType.EXTERIOR

var initial_transform := transform

var base_fov := fov

# The field of view to smoothly interpolate to.
var desired_fov := fov

# Position on the last physics frame (used to measure speed).
var previous_position := global_position

enum CameraType {
	EXTERIOR,
	INTERIOR,
	TOP_DOWN,
	MAX,  # Represents the size of the CameraType enum.
}

func _ready():
	update_camera()


func _input(event):
	if event.is_action_pressed(&"cycle_camera"):
		camera_type = wrapi(camera_type + 1, 0, CameraType.MAX) as CameraType
		update_camera()


func _physics_process(_delta):
	if camera_type == CameraType.EXTERIOR:
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
	elif camera_type == CameraType.TOP_DOWN:
		position.x = get_parent().global_transform.origin.x
		position.z = get_parent().global_transform.origin.z
		# Force rotation to prevent camera from being slanted after switching cameras while on a slope.
		rotation_degrees = Vector3(270, 180, 0)

	# Dynamic field of view based on car speed, with smoothing to prevent sudden changes on impact.
	desired_fov = clamp(base_fov + (abs(global_position.length() - previous_position.length()) - FOV_CHANGE_MIN_SPEED) * FOV_SPEED_FACTOR, base_fov, 100)
	fov = lerpf(fov, desired_fov, FOV_SMOOTH_FACTOR)

	# Turn a little up or down
	transform.basis = Basis(transform.basis[0], deg_to_rad(angle_v_adjust)) * transform.basis

	previous_position = global_position


func update_camera():
	match camera_type:
		CameraType.EXTERIOR:
			transform = initial_transform
		CameraType.INTERIOR:
			global_transform = get_node(^"../../InteriorCameraPosition").global_transform
		CameraType.TOP_DOWN:
			global_transform = get_node(^"../../TopDownCameraPosition").global_transform

	# This detaches the camera transform from the parent spatial node, but only
	# for exterior and top-down cameras.
	set_as_top_level(camera_type != CameraType.INTERIOR)
