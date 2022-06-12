tool
class_name AxisMarker3D, "res://marker/AxisMarker3D.svg"
extends Spatial

func _process(_delta):
	var holder: Spatial = get_child(0).get_child(0)
	var cube: Spatial = holder.get_child(0)
	# "Hide" the origin vector if the AxisMarker is at (0, 0, 0)
	if translation == Vector3():
		holder.transform = Transform()
		cube.transform = Transform().scaled(Vector3.ONE * 0.0001)
		return

	holder.transform = Transform(Basis(), translation / 2)
	holder.transform = holder.transform.looking_at(translation, Vector3.UP)
	holder.transform = get_parent().global_transform * holder.transform
	cube.transform = Transform(Basis().scaled(Vector3(0.1, 0.1, translation.length())))
