extends "res://state_machine/state.gd"
# The stagger state end with the stagger animation from the AnimationPlayer.
# The animation only affects the Body Sprite2D's modulate property so it
# could stack with other animations if we had two AnimationPlayer nodes.

func enter() -> void:
	owner.get_node(^"AnimationPlayer").play("stagger")


func _on_animation_finished(anim_name: String) -> void:
	assert(anim_name == "stagger")
	finished.emit("previous")
