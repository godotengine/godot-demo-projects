extends Camera

export var min_distance = 0.5
export var max_distance = 4.0
export var angle_v_adjust = 0.0

var collision_exception = []
var max_height = 2.0
var min_height = 0

func _ready():
	# Find collision exceptions for ray.
	var node = self
	while(node):
		if (node is RigidBody):
			collision_exception.append(node.get_rid())
			break
		else:
			node = node.get_parent()

	# This detaches the camera transform from the parent spatial node.
	set_as_toplevel(true)


func _physics_process(_delta):
	var target = get_parent().get_global_transform().origin
	var pos = get_global_transform().origin

	var from_target = pos - target

	# Check ranges.
	if from_target.length() < min_distance:
		from_target = from_target.normalized() * min_distance
	elif from_target.length() > max_distance:
		from_target = from_target.normalized() * max_distance

	# Check upper and lower height.
	if from_target.y > max_height:
		from_target.y = max_height
	if from_target.y < min_height:
		from_target.y = min_height

	pos = target + from_target

	look_at_from_position(pos, target, Vector3.UP)

	# Turn a little up or down
	var t = get_transform()
	t.basis = Basis(t.basis[0], deg2rad(angle_v_adjust)) * t.basis
	set_transform(t)
