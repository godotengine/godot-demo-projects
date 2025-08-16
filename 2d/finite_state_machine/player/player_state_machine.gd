extends "res://state_machine/state_machine.gd"

var player_state = preload("res://player/player_state.gd").player_state

@onready var idle: Node = $Idle
@onready var move: Node = $Move
@onready var jump: Node = $Jump
@onready var stagger: Node = $Stagger
@onready var attack: Node = $Attack

func _ready() -> void:
	states_map = {
		player_state.idle: idle,
		player_state.move: move,
		player_state.jump: jump,
		player_state.stagger: stagger,
		player_state.attack: attack,
	}


func _change_state(state_name: String) -> void:
	# The base state_machine interface this node extends does most of the work.
	if not _active:
		return
	if state_name in [player_state.stagger, player_state.jump, player_state.attack]:
		states_stack.push_front(states_map[state_name])
	if state_name == player_state.jump and current_state == move:
		jump.initialize(move.speed, move.velocity)

	super._change_state(state_name)


func _unhandled_input(event: InputEvent) -> void:
	# Here we only handle input that can interrupt states, attacking in this case,
	# otherwise we let the state node handle it.
	if event.is_action_pressed(player_state.attack):
		if current_state in [attack, stagger]:
			return
		_change_state(player_state.attack)
		return

	current_state.handle_input(event)
