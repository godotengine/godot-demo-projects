@tool
@icon("res://marker/AxisMarker2D.svg")
class_name AxisMarker2D
extends Node2D


func _process(_delta: float) -> void:
	var line: Line2D = get_child(0).get_child(0)
	var marker_parent: Node = get_parent()

	line.points[1] = transform.origin
	if marker_parent as Node2D != null:
		line.transform = marker_parent.global_transform
