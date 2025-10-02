class_name Bullet
extends RigidBody2D

var disabled := false

func _ready() -> void:
	($Timer as Timer).start()


func disable() -> void:
	if disabled:
		return

	($AnimationPlayer as AnimationPlayer).play("shutdown")
	disabled = true
