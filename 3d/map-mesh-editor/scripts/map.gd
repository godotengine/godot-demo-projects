class_name WorldMap extends Node3D

const RAY_DIST: int = 100

@onready var camera: Camera3D = $Camera3D
@onready var hex_grid: HexGrid = $HexGrid

var wireframe_enabled = false

func _ready() -> void:
	self.hex_grid.build_grid()
