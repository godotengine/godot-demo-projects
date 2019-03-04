extends RigidBody2D

class_name Bullet

# Member variables
var disabled = false


func _ready():
	($Timer as Timer).start()

func disable():
	if disabled:
		return
		
	($Anim as AnimationPlayer).play("shutdown")
	disabled = true