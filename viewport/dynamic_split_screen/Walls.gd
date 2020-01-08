tool
extends Spatial

# Set a random color to all objects in the 'walls' group

func _ready():
	randomize()
	var walls = get_tree().get_nodes_in_group("walls")
	for wall in walls:
		var material = SpatialMaterial.new()
		material.albedo_color = Color(randf(), randf(), randf())
		
		wall.material_override = material
