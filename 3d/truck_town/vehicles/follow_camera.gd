extends Camera3D

@export var min_distance := 2.0
@export var max_distance := 4.0
@export var angle_v_adjust := 0.0
@export var height := 1.5

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

	# Turn a little up or down
	transform.basis = Basis(transform.basis[0], deg_to_rad(angle_v_adjust)) * transform.basis
