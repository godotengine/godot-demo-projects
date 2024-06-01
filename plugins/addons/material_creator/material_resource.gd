@tool
extends Node
# NOTE: In theory, this would extend from Resource, but until saving and loading resources
# works in Godot, we'll stick with extending from Node and using JSON files to save/load data.
#
# See `material_import.gd` for more information.

var albedo_color := Color.BLACK
var metallic_strength := 0.0
var roughness_strength := 0.0


# Convert our data into an dictonary so we can convert it
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


# Convert the passed in string to a JSON dictonary, and then
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
	var material := StandardMaterial3D.new()

	material.albedo_color = albedo_color
	material.metallic = metallic_strength
	material.roughness = roughness_strength

	return material
