extends KinematicBody

# A simple program to rotate the model around

var model = null
const SPEED = 40

func _ready():
	model = get_node("Armature")
	set_process(true)


func _process(delta):
	model.rotation_degrees.y += delta * SPEED