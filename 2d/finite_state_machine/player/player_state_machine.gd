extends "res://state_machine/state_machine.gd"

var PLAYER_STATE = preload("res://player/player_state.gd").PLAYER_STATE

@onready var idle: Node = $Idle
@onready var move: Node = $Move
@onready var jump: Node = $Jump
@onready var stagger: Node = $Stagger
@onready var attack: Node = $Attack

func _ready() -> void:
	states_map = {
		PLAYER_STATE.idle: idle,
		PLAYER_STATE.move: move,
		PLAYER_STATE.jump: jump,
		PLAYER_STATE.stagger: stagger,
		PLAYER_STATE.attack: attack,
	}


func _change_state(state_name: String) -> void:
	# The base state_machine interface this node extends does most of the work.
	if not _active:
		return
	if state_name in [PLAYER_STATE.stagger, PLAYER_STATE.jump, PLAYER_STATE.attack]:
		states_stack.push_front(states_map[state_name])
	if state_name == PLAYER_STATE.jump and current_state == move:
		jump.initialize(move.speed, move.velocity)

	super._change_state(state_name)


func _unhandled_input(input_event: InputEvent) -> void:
	# Here we only handle input that can interrupt states, attacking in this case,
	# otherwise we let the state node handle it.
	if input_event.is_action_pressed(PLAYER_STATE.attack):
		if current_state in [attack, stagger]:
			return
		_change_state(PLAYER_STATE.attack)
		return

	current_state.handle_input(input_event)
