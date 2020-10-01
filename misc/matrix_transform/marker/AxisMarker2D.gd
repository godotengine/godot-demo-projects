tool
class_name AxisMarker2D, "res://marker/AxisMarker2D.svg"
extends Node2D

func _process(_delta):
	var line: Line2D = get_child(0).get_child(0)
	var marker_parent: Node2D = get_parent()

	line.points[1] = transform.origin
	if marker_parent as Node2D != null:
		line.transform = marker_parent.global_transform
