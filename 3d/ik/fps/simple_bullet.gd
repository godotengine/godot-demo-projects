extends RigidBody3D

const DESPAWN_TIME = 5

var timer = 0


func _ready():
	set_physics_process(true);


func _physics_process(delta):
	timer += delta
	if timer > DESPAWN_TIME:
		queue_free()
		timer = 0
