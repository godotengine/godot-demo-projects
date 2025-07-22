@tool
extends Resource

# Use export to make properties visible and serializable in the inspector and for resource saving/loading.
@export var albedo_color: Color = Color.BLACK
@export var metallic_strength: float = 0.0
@export var roughness_strength: float = 0.0

# Create a StandardMaterial3D from the resource's properties.
func make_material() -> StandardMaterial3D:
	var mat = StandardMaterial3D.new()
	mat.albedo_color = albedo_color
	mat.metallic = metallic_strength
	mat.roughness = roughness_strength
	return mat
