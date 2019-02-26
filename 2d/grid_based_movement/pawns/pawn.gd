extends Node2D

enum CellType { ACTOR, OBSTACLE, OBJECT }
export(CellType) var type = CellType.ACTOR
