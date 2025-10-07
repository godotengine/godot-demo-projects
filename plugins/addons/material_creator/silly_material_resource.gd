## Example class that can be imported, exported, loaded, saved, etc, in various ways.
##
## - To perform an editor import as a `SillyMaterialResource`, the class
##   `ImportSillyMatAsSillyMaterialResource` will handle files in the `res://`
##   folder ending in `.silly_mat_importable` and import them.
##   as long as "Silly Material Resource" is selected in the Import dock.
##   Then `ResourceLoader.load()` will return a read-only `SillyMaterialResource`.
##
## - To perform an editor import as a `StandardMaterial3D`, the class
##   `ImportSillyMatAsStandardMaterial3D` will handle files in the `res://`
##   folder ending in `.silly_mat_importable` and import them,
##   as long as "Standard Material 3D" is selected in the Import dock.
##   Then `ResourceLoader.load()` will return a read-only `StandardMaterial3D`.
##
## - To perform an editor load as a SillyMaterialResource, the class
##   `SillyMatFormatLoader` will handle files in the `res://`
##   folder ending in `.silly_mat_loadable` and load them.
##   Then `ResourceLoader.load()` will return a writeable `SillyMaterialResource`.
##   This can then be saved back to a file with `SillyMatFormatSaver`.
##
## - To perform a runtime (or editor) import into a StandardMaterial3D, run the
##   `read_from_file` function, which reads the data from a file and runs
##   `from_json_dictionary`, then run `to_material` to generate a material.
##
## - To perform a runtime (or editor) export of a StandardMaterial3D, run
##   `from_material` to convert a material, then run the `write_to_file`
##   function, which runs `to_json_dictionary` and saves this to a file.
##
## These functions should be placed in this class to support runtime imports
## and exports, but the editor classes can also make use of these functions,
## allowing the editor-only classes to be lightweight wrappers.
##
## For a more comprehensive example, see the GLTF module in Godot's source code.
## For a less comprehensive example, see the "simple_import_plugin" folder.
@tool
class_name SillyMaterialResource
extends Resource


# Use export to make properties visible in the inspector
# and serializable for resource saving/loading.
@export var albedo_color: Color = Color.BLACK
@export var metallic_strength: float = 0.0
@export var roughness_strength: float = 0.0


## Given a Dictionary parsed from JSON data, read in the data as a new SillyMaterialResource.
static func from_json_dictionary(json_dictionary: Dictionary) -> SillyMaterialResource:
	var ret := SillyMaterialResource.new()
	# Note: In an actual importer where you need to handle arbitrary user data,
	# you may wish to do things like checking if the key exists, checking if
	# the value is an array, checking if the array has a length of 3, checking
	# if each value in the array is a number, and so on.
	# For simplicity, these things are omitted from this demo's example code.
	var albedo_array: Array = json_dictionary["albedo_color"]
	ret.albedo_color.r = albedo_array[0]
	ret.albedo_color.g = albedo_array[1]
	ret.albedo_color.b = albedo_array[2]
	ret.metallic_strength = json_dictionary["metallic_strength"]
	ret.roughness_strength = json_dictionary["roughness_strength"]
	return ret


## Convert SillyMaterialResource data into a Dictionary for saving as JSON.
## To perform a runtime export of a StandardMaterial3D, run this function after `from_material`.
func to_json_dictionary() -> Dictionary:
	return {
		"albedo_color": [albedo_color.r, albedo_color.g, albedo_color.b],
		"metallic_strength": metallic_strength,
		"roughness_strength": roughness_strength,
	}


## Given a StandardMaterial3D, copy its data to a new SillyMaterialResource.
static func from_material(mat: StandardMaterial3D) -> SillyMaterialResource:
	var ret := SillyMaterialResource.new()
	ret.albedo_color = mat.albedo_color
	ret.metallic_strength = mat.metallic
	ret.roughness_strength = mat.roughness
	return ret


## Create a new StandardMaterial3D using the data in this SillyMaterialResource.
func to_material() -> StandardMaterial3D:
	var mat = StandardMaterial3D.new()
	mat.albedo_color = albedo_color
	mat.metallic = metallic_strength
	mat.roughness = roughness_strength
	return mat


## Wrapper around `from_json_dictionary` that reads from a file at the given path.
static func read_from_file(path: String) -> SillyMaterialResource:
	var mat_file := FileAccess.open(path, FileAccess.READ)
	if mat_file == null:
		return null
	var json_dict: Dictionary = JSON.parse_string(mat_file.get_as_text())
	return from_json_dictionary(json_dict)


## Wrapper around `to_json_dictionary` that writes to a file at the given path.
func write_to_file(path: String) -> Error:
	var mat_file := FileAccess.open(path, FileAccess.WRITE)
	if mat_file == null:
		return ERR_CANT_OPEN
	var json_dict: Dictionary = to_json_dictionary()
	mat_file.store_string(JSON.stringify(json_dict))
	mat_file.store_string("\n")
	return OK
