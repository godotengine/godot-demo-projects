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
		
## The pivot point of the circle, relative to the center.		
@export var pivot:Vector2:
	set(value):
		# since a pivot is basically a virtual Node2D inbetween,
		# we shift our own position here, so the pivot position
		# happens to be at local (0,0).
		
		# first undo any old displacement by the previous pivot
		global_position = global_transform * (-pivot)
		# then move to handle the displacement of the new pivot
		global_position = global_transform * (value)
		pivot = value
		queue_redraw()		


func _draw() -> void:
	draw_circle(-pivot, radius, color)
