# This will track the position of every pointer in its public `state` property, which is a
# Dictionary, in which each key is a pointer id (integer) and each value its position (Vector2).
# It works by listening to input events not handled by other means.
# It also remaps the pointer indices coming from the OS to the lowest available to be friendlier.
# It can be conveniently setup as a singleton.

extends Node

var state = {}
var _os2own = {}

func _unhandled_input(event):
	if event is InputEventScreenTouch:
		if event.pressed:
			# Down
			if !_os2own.has(event.index): # Defensively discard index if already known
				var ptr_id = _find_free_pointer_id()
				state[ptr_id] = event.position
				_os2own[event.index] = ptr_id
		else:
			# Up
			if _os2own.has(event.index): # Defensively discard index if not known
				var ptr_id = _os2own[event.index]
				state.erase(ptr_id)
				_os2own.erase(event.index)
		return true

	elif event is InputEventScreenDrag:
		# Move
		if _os2own.has(event.index): # Defensively discard index if not known
			var ptr_id = _os2own[event.index]
			state[ptr_id] = event.position
		return true

	return false

func _find_free_pointer_id():
	var used = state.keys()
	var i = 0
	while i in used:
		i += 1
	return i

