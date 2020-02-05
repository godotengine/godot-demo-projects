extends RigidBody2D
class_name Bullet


onready var animation_player = $AnimationPlayer


func destroy():
	animation_player.play("destroy")


func _on_body_entered(body):
	if body is Enemy:
		body.destroy()
