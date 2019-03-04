extends RigidBody2D

class_name Bullet


func _on_bullet_body_enter(body):
	if body.has_method("hit_by_bullet"):
		body.call("hit_by_bullet")

func _on_Timer_timeout():
	($Anim as AnimationPlayer).play("shutdown")
