extends MeshInstance

# class member variables go here, for example:
# var a = 2
# var b = "textvar"

func _ready():
	# Called every time the node is added to the scene.
	# Initialization here
	pass


var model = null
const SPEED = 40



func _process(delta):
	rotation_degrees.y += delta * SPEED