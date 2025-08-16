@tool
extends Node3D


func _ready():
	# Create spheres to represent various levels of material roughness and metallic.
	for roughness in 11:
		for metallic in 11:
			var sphere := MeshInstance3D.new()
			sphere.mesh = SphereMesh.new()
			# Center the spheres around the node origin.
			sphere.position = Vector3(roughness, 0, metallic) - Vector3(5, 0, 5)

			var material := StandardMaterial3D.new()
			material.albedo_color = Color(.5,.5,.5)
			material.roughness = roughness * 0.1
			material.metallic = metallic * 0.1
			sphere.material_override = material

			add_child(sphere)
