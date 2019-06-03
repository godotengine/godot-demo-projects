extends Node2D

enum CELL_TYPES { ACTOR, OBSTACLE, OBJECT }
export(CELL_TYPES) var type = CELL_TYPES.ACTOR

var active = true setget set_active

func set_active(value):
	active = value
	set_process(value)
	set_process_input(value)
