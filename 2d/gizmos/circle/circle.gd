@tool
class_name Circle
extends Node2D

## The radius of the circle
@export var radius:float = 100:
	set(value):
		# don't allow negative values
		radius = max(0, value)
		queue_redraw()


## The color of the circle
@export var color:Color:
	set(value):
		color = value
		queue_redraw()


func _draw() -> void:
	draw_circle(Vector2.ZERO, radius, color)
