extends Node3D

@export var rotation_speed: float = 1.0


func _process(delta: float) -> void:
	rotate_y(delta * rotation_speed)
