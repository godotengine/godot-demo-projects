extends Panel

@onready var fsm_node = get_node(^"../../Player/StateMachine")

func _process(_delta):
	var states_names = ""
	var numbers = ""
	var index = 0
	for state in fsm_node.states_stack:
		states_names += String(state.get_name()) + "\n"
		numbers += str(index) + "\n"
		index += 1
	%States.text = states_names
	%Numbers.text = numbers
