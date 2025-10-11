# This will track the position of every pointer in its public `state` property, which is a
# Dictionary, in which each key is a pointer index (integer) and each value its position (Vector2).
# It works by listening to input events not handled by other means.
# It also remaps the pointer indices coming from the OS to the lowest available to be friendlier.
# It can be conveniently setup as a singleton.
extends Node


var state: Dictionary[int, Vector2] = {}


func _unhandled_input(input_event: InputEvent) -> void:
	if input_event is InputEventScreenTouch:
		if input_event.pressed:
			# Down.
			state[input_event.index] = input_event.position
		else:
			# Up.
			state.erase(input_event.index)
		get_viewport().set_input_as_handled()

	elif input_event is InputEventScreenDrag:
		# Movement.
		state[input_event.index] = input_event.position
		get_viewport().set_input_as_handled()
