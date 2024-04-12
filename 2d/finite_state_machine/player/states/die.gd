extends "res://state_machine/state.gd"

# Initialize the state. E.g. change the animation.
func enter():
	owner.set_dead(true)
	owner.get_node(^"AnimationPlayer").play("die")


func _on_animation_finished(_anim_name):
	finished.emit("dead")
