extends "res://player/player_state.gd"

# Initialize the state. E.g. change the animation.
func enter() -> void:
	owner.set_dead(true)
	owner.get_node(^"AnimationPlayer").play(player_state.die)


func _on_animation_finished(_anim_name: String) -> void:
	finished.emit(player_state.dead)
