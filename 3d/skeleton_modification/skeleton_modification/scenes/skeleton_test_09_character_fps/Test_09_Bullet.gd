extends RigidBody3D

var destroy_timer:float = 0;
const MAX_LIFE_TIME:float = 2;

func _ready():
	set_process(true);

func _process(delta:float):
	destroy_timer += delta
	if (destroy_timer >= MAX_LIFE_TIME):
		queue_free();
