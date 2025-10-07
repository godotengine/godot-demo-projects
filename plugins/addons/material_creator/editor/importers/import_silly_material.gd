## Imports a `.silly_mat_importable` as a SillyMaterialResource.
## This class needs to be registered in the EditorPlugin to be used.
##
## Unlike loaders, importers can be configured, and multiple can exist in
## the same project. Selecting and configuring is done in the "Import" dock.
## However, imported files cannot be modified as easily as loaded files.
## See the "load_and_save" folder for an example of how to use loaders and savers.
##
## In actual projects, you should either choose EditorImportPlugin(s) for a
## configurable import, OR ResourceFormatLoader for a writeable resource load.
## Only one handling can exist at a given time for a given file extension.
## This demo exposes both by using 2 different file extensions.
@tool
class_name ImportSillyMatAsSillyMaterialResource
extends EditorImportPlugin


func _get_importer_name() -> String:
	return "demos.silly_material_importable.silly_material_resource"


func _get_visible_name() -> String:
	return "Silly Material Resource"


func _get_recognized_extensions() -> PackedStringArray:
	return ["silly_mat_importable"]


func _get_save_extension() -> String:
	return "res"


func _get_resource_type() -> String:
	# Note: This MUST be a native Godot type, it can't be a GDScript type.
	# Therefore it has to be "Resource" instead of "SillyMaterialResource".
	return "Resource"


func _get_preset_count() -> int:
	return 0


func _get_preset_name(preset: int) -> String:
	return "Default"


func _get_import_options(_path: String, preset: int) -> Array[Dictionary]:
	var ret: Array[Dictionary] = [
		{
			"name": "make_more_red",
			"default_value": false,
		}
	]
	return ret


func _get_import_order() -> int:
	return ResourceImporter.IMPORT_ORDER_DEFAULT


func _get_option_visibility(path: String, option: StringName, options: Dictionary) -> bool:
	return true


func _import(source_file: String, save_path: String, options: Dictionary, r_platform_variants: Array[String], r_gen_files: Array[String]) -> Error:
	var silly_mat_res := SillyMaterialResource.read_from_file(source_file)
	if options.has("make_more_red") and options["make_more_red"]:
		silly_mat_res.albedo_color = silly_mat_res.albedo_color.lerp(Color.RED, 0.5)
	# This will save to a file path like `res://.godot/imported/something.res`.
	var imported_path: String = "%s.%s" % [save_path, _get_save_extension()]
	return ResourceSaver.save(silly_mat_res, imported_path)
