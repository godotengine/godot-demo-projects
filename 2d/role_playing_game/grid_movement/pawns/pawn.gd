class_name Pawn
extends Node2D

enum CellType {
	ACTOR,
	OBSTACLE,
	OBJECT,
}

@export var type := CellType.ACTOR

var active := true: set = set_active

func set_active(value: bool) -> void:
	active = value
	set_process(value)
	set_process_input(value)
