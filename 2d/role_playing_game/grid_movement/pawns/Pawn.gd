class_name Pawn
extends Node2D

enum CellType { ACTOR, OBSTACLE, OBJECT }
#warning-ignore:unused_class_variable
@export var type: CellType = CellType.ACTOR

var active = true:
	set(value):
		# TODO: Manually copy the code from this method.
		set_active(value)

func set_active(value):
	active = value
	set_process(value)
	set_process_input(value)
