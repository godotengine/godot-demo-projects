extends KinematicBody2D

signal state_changed

var look_direction = Vector2()

var current_state = null
var states_stack = []

onready var states_map = {
	'idle': $States/Idle,
	'move': $States/Move,
	'jump': $States/Jump,
	'shoot': $States/Shoot,
}

func _ready():
	states_stack.push_front($States/Idle)
	current_state = states_stack[0]
	_change_state('idle')


# Delegate the call to the state
func _physics_process(delta):
	var new_state = current_state.update(self, delta)
	if new_state:
		_change_state(new_state)


func _input(event):
	var new_state = current_state.handle_input(self, event)
	if new_state:
		_change_state(new_state)


# Exit the current state, change it and enter the new one
func _change_state(state_name):
	# The pushdown mechanism isn't very useful in this example.
	# If the player stops moving mid-air Jump will still return to move
#	print('Exiting %s and enterig %s' % [current_state.get_name(), new_state.get_name()])
	current_state.exit(self)

	# removing state previously pushed on the stack
	if state_name == 'previous':
		states_stack.pop_front()
	elif state_name in ['jump', 'shoot']:
		states_stack.push_front(states_map[state_name])
		if state_name == 'jump':
			$States/Jump.initialize(current_state.speed, current_state.velocity)
	else:
		# pushing new state on to the stack
		var new_state = states_map[state_name]
		states_stack[0] = new_state

	# We only reinitialize the state when we don't use the pushdown automaton
	if state_name != 'previous':
		current_state.enter(self)

	current_state = states_stack[0]
	emit_signal('state_changed', current_state.get_name())
