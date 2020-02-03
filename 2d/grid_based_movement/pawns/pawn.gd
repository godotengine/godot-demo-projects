extends Node2D

enum CellType { ACTOR, OBSTACLE, OBJECT }
#warning-ignore:unused_class_variable
export(CellType) var type = CellType.ACTOR
