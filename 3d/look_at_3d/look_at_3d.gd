extends KinematicBody

# Member variables
const MODE_DIRECT = 0
const MODE_CONSTANT = 1
const MODE_SMOOTH = 2

const ROTATION_SPEED = 0.1
const SMOOTH_SPEED = 0.01

const UP = Vector3(0,1,0)

var value = 0

export(int, "Direct", "Constant", "Smooth") var mode = MODE_DIRECT

onready var origin = get_global_transform().origin

func _process(delta):
	var lookTarget = get_node("../KinematicBody_ball")
	
	if (mode == MODE_DIRECT):
		var lookPos = lookTarget.get_transform().origin
		look_at(lookPos,Vector3(0,1,0))
		
		## QUATERNION EQUIVALENT
#		var t = get_transform()
#		var lookDir = get_node(lookTarget).get_transform().origin - t.origin
#		var rotTransform = t.looking_at(get_transform().origin+lookDir,Vector3(0,1,0))
#		var thisRotation = Quat(rotTransform.basis)
#		set_transform(Transform(thisRotation,t.origin))

	elif (mode == MODE_CONSTANT):
		var t = get_transform()
		var lookDir = lookTarget.get_transform().origin - t.origin
		var rotTransform = t.looking_at(lookDir, UP)
		var thisRotation = Quat(t.basis).slerpni(rotTransform.basis, value)
		value += delta
		if value > ROTATION_SPEED:
			value = ROTATION_SPEED
		set_transform(Transform(thisRotation,t.origin))

	elif (mode == MODE_SMOOTH):
		var t = get_transform()
		var lookDir = lookTarget.get_transform().origin - t.origin
		var rotTransform = t.looking_at(get_transform().origin + lookDir, UP)
		var thisRotation = Quat(t.basis).slerp(rotTransform.basis, SMOOTH_SPEED)
		set_transform(Transform(thisRotation, t.origin))


func _ready():
	set_process(true)