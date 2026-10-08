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

		# Set our mesh so we can occlude the surface (see material override).
		if _plane_tracker.has_method("get_vertices"):
			# Available in 4.8 onwards, get our mesh data
			var org_vertices = _plane_tracker.get_vertices()
			var org_indices = _plane_tracker.get_indices()

			if not org_vertices.is_empty() and not org_indices.is_empty():
				# We need to make sure very triangle has unique vertices
				# for our wireframe shader.
				var vertices := PackedVector3Array()
				vertices.resize(org_indices.size())
				for i in range(org_indices.size()):
					var v = org_vertices[org_indices[i]]
					vertices[i] = Vector3(v.x, v.y, 0.0)

				var mesh_array := Array()
				mesh_array.resize(Mesh.ARRAY_MAX)
				mesh_array[Mesh.ARRAY_VERTEX] = vertices

				var new_mesh := ArrayMesh.new()
				new_mesh.add_surface_from_arrays(Mesh.PRIMITIVE_TRIANGLES, mesh_array)
				$StaticBody3D/MeshInstance3D.mesh = new_mesh
		else:
			# `get_mesh` is cached and the better option if you're just interested
			# in the geometry. But it will fail with our wireframe shader.
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
