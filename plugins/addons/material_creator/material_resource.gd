@tool
extends Resource
class_name SillyMaterialResource

# Use export to make properties visible and serializable in the inspector and for resource saving/loading.
@export var albedo_color: Color = Color.BLACK
@export var metallic_strength: float = 0.0
@export var roughness_strength: float = 0.0


# Create a StandardMaterial3D from the resource's properties.
# Convert our data into an dictionary so we can convert it
# into the JSON format.
func make_json() -> String:
	var json_dict := {}

	json_dict["albedo_color"] = {}
	json_dict["albedo_color"]["r"] = albedo_color.r
	json_dict["albedo_color"]["g"] = albedo_color.g
	json_dict["albedo_color"]["b"] = albedo_color.b

	json_dict["metallic_strength"] = metallic_strength
	json_dict["roughness_strength"] = roughness_strength

	return JSON.stringify(json_dict)


# Convert the passed in string to a JSON dictionary, and then
# fill in our data.
func from_json(json_dict_as_string: String) -> void:
	var json_dict: Dictionary = JSON.parse_string(json_dict_as_string)

	albedo_color.r = json_dict["albedo_color"]["r"]
	albedo_color.g = json_dict["albedo_color"]["g"]
	albedo_color.b = json_dict["albedo_color"]["b"]

	metallic_strength = json_dict["metallic_strength"]
	roughness_strength = json_dict["roughness_strength"]


# Make a StandardMaterial3D using our variables.
func make_material() -> StandardMaterial3D:
	var mat = StandardMaterial3D.new()
	mat.albedo_color = albedo_color
	mat.metallic = metallic_strength
	mat.roughness = roughness_strength
	return mat
