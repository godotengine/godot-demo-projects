extends "res://player/player_state.gd"

func enter() -> void:
	owner.get_node(^"AnimationPlayer").play(PLAYER_STATE.idle)


func _on_Sword_attack_finished() -> void:
	finished.emit(PLAYER_STATE.previous)
