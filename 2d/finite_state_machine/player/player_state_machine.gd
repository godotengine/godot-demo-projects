extends "res://state_machine/state_machine.gd"

@onready var idle: Node = $Idle
@onready var move: Node = $Move
@onready var jump: Node = $Jump
@onready var stagger: Node = $Stagger
@onready var attack: Node = $Attack

func _ready() -> void:
	states_map = {
		"idle": idle,
		"move": move,
		"jump": jump,
		"stagger": stagger,
		"attack": attack,
	}


func _change_state(state_name: String) -> void:
	# The base state_machine interface this node extends does most of the work.
	if not _active:
		return
	if state_name in ["stagger", "jump", "attack"]:
		states_stack.push_front(states_map[state_name])
	if state_name == "jump" and current_state == move:
		jump.initialize(move.speed, move.velocity)

	super._change_state(state_name)


func _unhandled_input(event: InputEvent) -> void:
	# Here we only handle input that can interrupt states, attacking in this case,
	# otherwise we let the state node handle it.
	if event.is_action_pressed("attack"):
		if current_state in [attack, stagger]:
			return
		_change_state("attack")
		return

	current_state.handle_input(event)
