extends Node2D


onready var character = $Character


func _unhandled_input(event):
	if not event.is_action_pressed("click"):
		return
	character.set_target_location(get_global_mouse_position())
