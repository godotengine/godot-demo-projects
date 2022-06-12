extends Node
# This will track the position of every pointer in its public `state` property, which is a
# Dictionary, in which each key is a pointer index (integer) and each value its position (Vector2).
# It works by listening to input events not handled by other means.
# It also remaps the pointer indices coming from the OS to the lowest available to be friendlier.
# It can be conveniently setup as a singleton.

var state = {}

func _unhandled_input(event):
	if event is InputEventScreenTouch:
		if event.pressed: # Down.
			state[event.index] = event.position
		else: # Up.
			state.erase(event.index)
		get_tree().set_input_as_handled()

	elif event is InputEventScreenDrag: # Movement.
		state[event.index] = event.position
		get_tree().set_input_as_handled()
