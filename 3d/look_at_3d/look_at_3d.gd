
tool
extends KinematicBody

# Member variables
const MODE_DIRECT = 0
const MODE_DIRECT_TRANSFORM = 1
const MODE_CONSTANT = 2
const MODE_SMOOTH = 3

const SMOOTH_SPEED = 10.0

const UP = Vector3(0,1,0)

var value = 0

export(int, "Direct", "Direct transform", "Constant", "Smooth") var mode = MODE_DIRECT
export(NodePath) var target_nodepath = "../target"

func _ready():
	set_process(true)


func _process(delta):
	var look_target = get_node(target_nodepath)
	
	# Store the current transform of our object
	var t = get_transform()
	
	# Store the target position
	var target_position = look_target.get_transform().origin
	
	# Direct mode simply call look_at(position, axis) that creates the rotation transformation
	# and applies it to the object for us.
	if (mode == MODE_DIRECT):
		look_at(target_position, UP)
	
	# Direct transform mode is equivalent to Direct mode, it simply demonstrates the "manual" 
	# calculation of the rotation transform that points at target position, then we apply it ourselves.
	elif (mode == MODE_DIRECT_TRANSFORM):
		var rotation_transform = t.looking_at(target_position, UP)
		set_transform(rotation_transform)

	# Constant mode defines a similar rotation transform pointing at target_position.
	# Then we create a quaternion based on our object's current transform, and we perform a
	# spherical-linear interpolation with the target rotation transform, weighted by delta.
	# Finally we apply the resulting Quaternion converted to a Transform.
	elif (mode == MODE_CONSTANT):
		var rotation_transform = t.looking_at(target_position, UP)
		var quaternion_rotation = Quat(t.basis).slerpni(rotation_transform.basis, delta)
		set_transform(Transform(quaternion_rotation, t.origin))
		
	# Smooth mode smooths the animation
	elif (mode == MODE_SMOOTH):
		var rotation_transform = t.looking_at(target_position, UP)
		rotation_transform.basis.x = rotation_transform.basis.x.rotated(UP, SMOOTH_SPEED*delta)
		set_transform(rotation_transform)
		
