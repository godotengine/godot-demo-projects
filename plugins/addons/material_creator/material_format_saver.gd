@tool
extends ResourceFormatSaver
class_name SillyMatFormatSaver
## Custom saver for the .silly_mat file format.
## Works together with SillyMatFormatLoader to make SillyMaterialResource.


## This saver only supports SilluMaterialResource.
func _recognize(resource: Resource) -> bool:
	return resource is SillyMaterialResource


## Return list of file extensions this saver will write.
func _get_recognized_extensions(resource: Resource) -> PackedStringArray:
	return PackedStringArray(["silly_mat"])


## Main save function.
## Serializes a SillyMaterialResource into .silly_mat format.
##
## It will write simple text-based format, one property per line.
func _save(resource: Resource, path: String, flags: int) -> int:
	var mat_res: SillyMaterialResource = resource as SillyMaterialResource
	if mat_res == null:
		return ERR_INVALID_DATA

	var mat_file := FileAccess.open(path, FileAccess.WRITE)
	if mat_file == null:
		return ERR_CANT_OPEN

	mat_file.store_line("SILLY_MAT v1")
	mat_file.store_line(mat_res.albedo_color.to_html(true)) # Stored in HTML hex.
	mat_file.store_line(str(mat_res.metallic_strength))
	mat_file.store_line(str(mat_res.roughness_strength))
	return OK
