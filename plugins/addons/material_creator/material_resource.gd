tool
extends Node

# NOTE: in theory this would extend from resource, but until saving and loading resources
# works in godot, we'll stick with extending from node
# and using JSON files to save/load data
#
# See material_import.gd for more information

var albedo_color
var metallic_strength
var roughness_strength

func init():
	albedo_color = Color()
	metallic_strength = 0
	roughness_strength = 0


# Convert our data into an dictonary so we can convert it
# into the JSON format
func make_json():
	var json_dict = {}

	json_dict["albedo_color"] = {}
	json_dict["albedo_color"]["r"] = albedo_color.r
	json_dict["albedo_color"]["g"] = albedo_color.g
	json_dict["albedo_color"]["b"] = albedo_color.b

	json_dict["metallic_strength"] = metallic_strength
	json_dict["roughness_strength"] = roughness_strength

	return to_json(json_dict)


# Convert the passed in string to a json dictonary, and then
# fill in our data.
func from_json(json_dict_as_string):
	var json_dict = parse_json(json_dict_as_string)

	albedo_color.r = json_dict["albedo_color"]["r"]
	albedo_color.g = json_dict["albedo_color"]["g"]
	albedo_color.b = json_dict["albedo_color"]["b"]

	metallic_strength = json_dict["metallic_strength"]
	roughness_strength = json_dict["roughness_strength"]


# Make a SpatialMaterial using our variables.
func make_material():
	var mat = SpatialMaterial.new()

	mat.albedo_color = albedo_color
	mat.metallic = metallic_strength
	mat.roughness = roughness_strength

	return mat
