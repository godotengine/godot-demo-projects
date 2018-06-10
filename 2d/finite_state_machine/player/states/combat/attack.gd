"""
The stagger state end with the stagger animation from the AnimationPlayer
The animation only affects the Body Sprite"s modulate property so 
it could stack with other animations if we had two AnimationPlayer nodes
"""
extends "../state.gd"


func enter(host):
	host.get_node("AnimationPlayer").play("idle")


func _on_Sword_attack_finished():
	emit_signal("finished", "previous")
