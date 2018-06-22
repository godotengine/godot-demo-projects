extends Panel

onready var fsm_node = get_node("../Player/StateMachine")

func _ready():
	set_as_toplevel(true)

func _process(delta):
	var states_names = ''
	var numbers = ''
	var index = 0
	for state in fsm_node.states_stack:
		states_names += state.get_name() + '\n'
		numbers += str(index) + '\n'
		index += 1

	$States.text = states_names
	$Numbers.text = numbers
