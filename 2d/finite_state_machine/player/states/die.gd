extends "state.gd"


# Initialize the state. E.g. change the animation
func enter(host):
	host.set_dead(true)
	host.get_node("AnimationPlayer").play("die")

func _on_animation_finished(anim_name):
	emit_signal("finished", "dead")
