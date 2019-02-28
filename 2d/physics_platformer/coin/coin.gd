extends Area2D

class_name Coin

# Member variables
var taken = false


func _on_body_enter( body ):
	if not taken and body is Player:
		($anim as AnimationPlayer).play("taken")
		taken = true
"""
func _on_coin_area_enter(area):
	pass # replace with function body

func _on_coin_area_enter_shape(area_id, area, area_shape, area_shape):
	pass # replace with function body
"""