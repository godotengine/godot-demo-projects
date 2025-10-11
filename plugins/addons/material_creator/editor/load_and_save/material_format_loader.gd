## Custom loader for the `.silly_mat_loadable` file format.
## Works together with `SillyMatFormatSaver` to support saving and loading.
## This class needs to be registered in the EditorPlugin to be used.
##
## Loaders can easily have the loaded data be modified and saved back into
## the file. However, only one loader can exist, and the loading cannot be
## configured, unlike importers which are configurable in the "Import" dock.
## See the "importers" folder for two examples of how to use importers.
##
## In actual projects, you should either choose ResourceFormatLoader for a
## writeable resource load, OR EditorImportPlugin(s) for a configurable import.
## Only one handling can exist at a given time for a given file extension.
## This demo exposes both by using 2 different file extensions.
@tool
class_name SillyMatFormatLoader
extends ResourceFormatLoader


## Callback to return an array of the file extensions this loader can load.
func _get_recognized_extensions() -> PackedStringArray:
	return PackedStringArray(["silly_mat_loadable"])


## Callback to return the resource type name based on file extension.
func _get_resource_type(path: String) -> String:
	if path.get_extension() == "silly_mat_loadable":
		return "SillyMaterialResource"
	return ""


## Callback to return what resource type this loader handles.
func _handles_type(type_name: StringName) -> bool:
	return type_name == &"SillyMaterialResource"


## Main callback to actually perform the loading.
func _load(path: String, original_path: String, use_sub_threads: bool, cache_mode: int) -> Variant:
	return SillyMaterialResource.read_from_file(original_path)
