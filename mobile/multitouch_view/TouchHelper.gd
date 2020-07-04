extends Node
# This will track the position of every pointer in its public `state` property, which is a
# Dictionary, in which each key is a pointer id (integer) and each value its position (Vector2).
# It works by listening to input events not handled by other means.
# It also remaps the pointer indices coming from the OS to the lowest available to be friendlier.
# It can be conveniently setup as a singleton.

var state = {}
var _os2own = {}

func _unhandled_input(event):
	if event is InputEventScreenTouch:
		if event.pressed: # Down.
			if !_os2own.has(event.index): # Defensively discard index if already known.
				var ptr_id = state.size()
				state[ptr_id] = event.position
				_os2own[event.index] = ptr_id
		else: # Up.
			if _os2own.has(event.index): # Defensively discard index if not known.
				var ptr_id = _os2own[event.index]
				state.erase(ptr_id)
				_os2own.erase(event.index)
		get_tree().set_input_as_handled()
		
	elif event is InputEventScreenDrag: # Movement.
		if _os2own.has(event.index): # Defensively discard index if not known.
			var ptr_id = _os2own[event.index]
			state[ptr_id] = event.position
		get_tree().set_input_as_handled()
