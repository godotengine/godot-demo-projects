extends "res://state_machine/state.gd"

func enter() -> void:
	owner.get_node(^"AnimationPlayer").play("idle")


func _on_Sword_attack_finished() -> void:
	finished.emit("previous")
