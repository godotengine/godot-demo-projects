extends Node
## A simple script that rotates the model.

@onready var model: Node3D = $Model


func _process(delta: float) -> void:
	model.rotation.y += delta * 0.7
