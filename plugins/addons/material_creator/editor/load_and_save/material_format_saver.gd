## Custom saver for the `.silly_mat_loadable` file format.
## Works together with `SillyMatFormatLoader` to support loading and saving.
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
class_name SillyMatFormatSaver
extends ResourceFormatSaver


## Callback to return an array of the file extensions this saver can write.
func _get_recognized_extensions(resource: Resource) -> PackedStringArray:
	return PackedStringArray(["silly_mat_loadable"])


## Callback to determine if a given Resource is supported by this saver.
func _recognize(resource: Resource) -> bool:
	return resource is SillyMaterialResource


## Main callback to actually perform the saving.
func _save(resource: Resource, path: String, flags: int) -> Error:
	var mat_res: SillyMaterialResource = resource as SillyMaterialResource
	if mat_res == null:
		return ERR_INVALID_DATA
	return mat_res.write_to_file(path)
