class_name Coin

extends Area2D


var taken = false

func _on_coin_body_enter(body):
	if not taken and body is Player:
		($anim as AnimationPlayer).play("taken")
		taken = true
