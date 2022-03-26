extends Camera3D

const MAX_HEIGHT = 2.0
const MIN_HEIGHT = 0

@export var min_distance = 0.5
@export var max_distance = 3.5
@export var angle_v_adjust = 0.0
@export var autoturn_ray_aperture = 25
@export var autoturn_speed = 50

var collision_exception = []

func _ready():
	# Find collision exceptions for ray.
	var node = self
	while node:
		if node is RigidBody3D:
			collision_exception.append(node.get_rid())
			break
		else:
			node = node.get_parent()
	set_physics_process(true)
	# This detaches the camera transform from the parent spatial node.
	set_as_top_level(true)


func _physics_process(dt):
	var target = get_parent().get_global_transform().origin
	var pos = get_global_transform().origin

	var delta = pos - target

	# Regular delta follow.

	# Check ranges.
	if delta.length() < min_distance:
		delta = delta.normalized() * min_distance
	elif  delta.length() > max_distance:
		delta = delta.normalized() * max_distance

	# Check upper and lower height.
	delta.y = clamp(delta.y, MIN_HEIGHT, MAX_HEIGHT)

	# Check autoturn.
	var ds = PhysicsServer3D.space_get_direct_state(get_world_3d().get_space())

	var col_left = ds.intersect_ray(target, target + Basis(Vector3.UP, deg2rad(autoturn_ray_aperture)) * (delta), collision_exception)
	var col = ds.intersect_ray(target, target + delta, collision_exception)
	var col_right = ds.intersect_ray(target, target + Basis(Vector3.UP, deg2rad(-autoturn_ray_aperture)) * (delta), collision_exception)

	if not col.is_empty():
		# If main ray was occluded, get camera closer, this is the worst case scenario.
		delta = col.position - target
	elif not col_left.is_empty() and col_right.is_empty():
		# If only left ray is occluded, turn the camera around to the right.
		delta = Basis(Vector3.UP, deg2rad(-dt * (autoturn_speed)) * delta)
	elif col_left.is_empty() and not col_right.is_empty():
		# If only right ray is occluded, turn the camera around to the left.
		delta = Basis(Vector3.UP, deg2rad(dt  *autoturn_speed)) * (delta)
	# Do nothing otherwise, left and right are occluded but center is not, so do not autoturn.

	# Apply lookat.
	if delta == Vector3():
		delta = (pos - target).normalized() * 0.0001

	pos = target + delta

	look_at_from_position(pos, target, Vector3.UP)

	# Turn a little up or down.
	var t = get_transform()
	t.basis = Basis(t.basis[0], deg2rad(angle_v_adjust)) * t.basis
	set_transform(t)
