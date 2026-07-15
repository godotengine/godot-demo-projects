@tool
@icon("res://marker/AxisMarker2D.svg")
class_name AxisMarker2D
extends Node2D


func _process(_delta: float) -> void:
	var line: Line2D = get_child(0).get_child(0)
	var marker_parent: Node = get_parent()

	# Modify a copy of the points array and assign it to the Line2D's `points` property.
	# Otherwise, we modify a copy of the property which ends up having no effect
	# (see the `confusable_temporary_modification` GDScript warning).
	var points: PackedVector2Array = line.points
	points[1] = transform.origin
	line.points = points

	if marker_parent as Node2D != null:
		line.transform = marker_parent.global_transform
