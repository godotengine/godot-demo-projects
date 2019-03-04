extends Area2D

class_name Coin

# Member variables
var taken = false


func _on_body_enter( body ):
	if not taken and body is Player:
		($Anim as AnimationPlayer).play("taken")