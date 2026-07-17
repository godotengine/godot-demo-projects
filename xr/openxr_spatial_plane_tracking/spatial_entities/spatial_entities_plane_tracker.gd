extends XRAnchor3D

## This script handles plane tracked anchors.
## A static collision will be maintained once we
## have a collider shape.
## We will also display a mesh that will occlude any
## objects behind our surface.

@export var material: Material:
	set(value):
		material = value
		if is_inside_tree():
			$StaticBody3D/MeshInstance3D.material_override = material

var _plane_tracker: OpenXRPlaneTracker

func _update_mesh_and_collision():
	if _plane_tracker:
		# Place our static body using our offset so both collision
		# and mesh are positioned correctly.
		$StaticBody3D.transform = _plane_tracker.get_mesh_offset()

		# Set our mesh so we can occlude the surface (see material override)
		var new_mesh = _plane_tracker.get_mesh()
		if $StaticBody3D/MeshInstance3D.mesh != new_mesh:
			$StaticBody3D/MeshInstance3D.mesh = new_mesh

		# And set our shape so we can have things collide with our surface.
		var new_shape = _plane_tracker.get_shape()
		if $StaticBody3D/CollisionShape3D.shape != new_shape:
			$StaticBody3D/CollisionShape3D.shape = new_shape


func _on_mesh_changed():
	_update_mesh_and_collision()


func _ready():
	$StaticBody3D/MeshInstance3D.material_override = material

	_plane_tracker = XRServer.get_tracker(tracker)
	if _plane_tracker:
		print("Adding scene for ", _plane_tracker.description)
		$Description.text = _plane_tracker.description

		_update_mesh_and_collision()

		_plane_tracker.mesh_changed.connect(_on_mesh_changed)
