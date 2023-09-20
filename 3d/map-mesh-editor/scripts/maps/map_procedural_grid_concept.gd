extends Node3D

@onready var grid: Grid = $Grid

func _ready():
	self.grid.build_grid()
