tool
extends Panel

func _ready():
	set_as_toplevel(true)

func _on_Player_state_changed(states_stack):
	var states_names = ''
	var numbers = ''
	var index = 0
	for state in states_stack:
		states_names += state.get_name() + '\n'
		numbers += str(index) + '\n'
		index += 1

	$States.text = states_names
	$Numbers.text = numbers

