extends "res://player/player_state.gd"

func enter() -> void:
	owner.get_node(^"AnimationPlayer").play(player_state.idle)


func _on_Sword_attack_finished() -> void:
	finished.emit(player_state.previous)
