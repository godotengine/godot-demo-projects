
extends Area

# Member variables
var taken = false


func _on_coin_body_enter(body):
	if (not taken and body extends preload("res://player.gd")):
		get_node("anim").play("take")
		taken = true


func _on_anim_finished():
	if get_node("anim").get_current_animation() == "take":
		queue_free()
		