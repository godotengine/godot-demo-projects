extends Camera3D

const MAX_HEIGHT = 2.0
const MIN_HEIGHT = 0.0

var collision_exception: Array[RID] = []

@export var min_distance := 0.5
@export var max_distance := 3.5
@export var angle_v_adjust := 0.0
@export var autoturn_ray_aperture := 25.0
@export var autoturn_speed := 50.0

func _ready() -> void:
	# Find collision exceptions for ray.
	var node: Node = self
	while is_instance_valid(node):
		if node is RigidBody3D:
			collision_exception.append(node.get_rid())
			break
		else:
			node = node.get_parent()
	set_physics_process(true)
	# This detaches the camera transform from the parent spatial node.
	set_as_top_level(true)


func _physics_process(delta: float) -> void:
	var target := (get_parent() as Node3D).get_global_transform().origin
	var pos := get_global_transform().origin

	var difference := pos - target

	# Regular delta follow.

	# Check ranges.
	if difference.length() < min_distance:
		difference = difference.normalized() * min_distance
	elif  difference.length() > max_distance:
		difference = difference.normalized() * max_distance

	# Check upper and lower height.
	difference.y = clamp(difference.y, MIN_HEIGHT, MAX_HEIGHT)

	# Check autoturn.
	var ds := PhysicsServer3D.space_get_direct_state(get_world_3d().get_space())

	var col_left := ds.intersect_ray(PhysicsRayQueryParameters3D.create(
			target,
			target + Basis(Vector3.UP, deg_to_rad(autoturn_ray_aperture)) * (difference),
			0xffffffff,
			collision_exception
	))
	var col := ds.intersect_ray(PhysicsRayQueryParameters3D.create(
			target,
			target + difference,
			0xffffffff,
			collision_exception
	))
	var col_right := ds.intersect_ray(PhysicsRayQueryParameters3D.create(
			target,
			target + Basis(Vector3.UP, deg_to_rad(-autoturn_ray_aperture)) * (difference),
			0xffffffff,
			collision_exception
	))

	if not col.is_empty():
		# If main ray was occluded, get camera closer, this is the worst case scenario.
		difference = col.position - target
	elif not col_left.is_empty() and col_right.is_empty():
		# If only left ray is occluded, turn the camera around to the right.
		difference = Basis(Vector3.UP, deg_to_rad(-delta * (autoturn_speed))) * difference
	elif col_left.is_empty() and not col_right.is_empty():
		# If only right ray is occluded, turn the camera around to the left.
		difference = Basis(Vector3.UP, deg_to_rad(delta * autoturn_speed)) * difference
	# Do nothing otherwise, left and right are occluded but center is not, so do not autoturn.

	# Apply lookat.
	if difference.is_zero_approx():
		difference = (pos - target).normalized() * 0.0001

	pos = target + difference

	look_at_from_position(pos, target, Vector3.UP)

	# Turn a little up or down.
	transform.basis = Basis(transform.basis[0], deg_to_rad(angle_v_adjust)) * transform.basis
