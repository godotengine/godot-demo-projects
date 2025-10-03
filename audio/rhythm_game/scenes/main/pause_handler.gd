# Pause logic is separated out since it needs to run with PROCESS_MODE_ALWAYS.
extends Node


func _process(_delta: float) -> void:
	if Input.is_action_just_pressed("pause"):
		get_tree().paused = not get_tree().paused
		$"../Control/PauseLabel".visible = get_tree().paused
