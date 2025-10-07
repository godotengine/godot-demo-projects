@tool
extends ResourceFormatLoader
class_name SillyMatFormatLoader
## Custom loader for the .silly_mat file format.
## Allows Godot to recognize and load SillyMaterialResource files.
## Register this loader in the EditorPlugin to enable saving/loading resources.


## Returns the list of file extensions this loader supports.
func _get_recognized_extensions() -> PackedStringArray:
	# Returns only ".silly_mat"
	return PackedStringArray(["silly_mat"])


## Returns what resource type this loader handles.
func _handles_type(typename: StringName) -> bool:
	return typename == "SillyMaterialResource"


## Returns the resource type name based on file extension.
func _get_resource_type(path: String) -> String:
	return "SillyMaterialResource" if path.get_extension() == "silly_mat" else ""


## Main load function. Reads .silly_mat and constructs a SillyMaterialResource.
func _load(path: String, original_path: String, use_sub_threads, cache_mode):
	var mat_file = FileAccess.open(path, FileAccess.READ)
	if mat_file == null:
		return ERR_CANT_OPEN

	# Check header line to validate file format version.
	if mat_file.get_line() != "SILLY_MAT v1":
		return ERR_PARSE_ERROR

	# Create and Fill SillyMaterialResource
	var mat_res: SillyMaterialResource = SillyMaterialResource.new()
	mat_res.albedo_color = Color(mat_file.get_line())
	mat_res.metallic_strength = float(mat_file.get_line())
	mat_res.roughness_strength = float(mat_file.get_line())
	return mat_res
