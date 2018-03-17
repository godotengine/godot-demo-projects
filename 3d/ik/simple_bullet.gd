extends RigidBody

const KILL_TIME = 5
var timer = 0

func _ready():
	set_physics_process(true);

func _physics_process(delta):
	timer += delta
	if timer > KILL_TIME:
		queue_free()
		timer = 0 # Make sure we are destroyed before we call this again!
