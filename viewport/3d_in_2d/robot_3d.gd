extends Node

# A simple script to rotate the model.
@onready var model = $Model

func _process(delta):
	model.rotate_y(delta * 0.7)
