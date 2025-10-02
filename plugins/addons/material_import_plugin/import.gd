@tool
extends EditorImportPlugin

enum Preset {
	PRESET_DEFAULT,
}


func _get_importer_name() -> String:
	return "demos.sillymaterial"


func _get_visible_name() -> String:
	return "Silly Material"


func _get_recognized_extensions() -> PackedStringArray:
	return ["mtxt"]


func _get_save_extension() -> String:
	return "res"


func _get_resource_type() -> String:
	return "Material"


func _get_preset_count() -> int:
	return Preset.size()


func _get_preset_name(preset: Preset) -> String:
	match preset:
		Preset.PRESET_DEFAULT:
			return "Default"
		_:
			return "Unknown"


func _get_import_options(_path: String, preset: Preset) -> Array[Dictionary]:
	match preset:
		Preset.PRESET_DEFAULT:
			return [{
				"name": "use_red_anyway",
				"default_value": false,
			}]
		_:
			return []


func _get_import_order() -> int:
	return ResourceImporter.IMPORT_ORDER_DEFAULT


func _get_option_visibility(path: String, option: StringName, options: Dictionary) -> bool:
	return true


func _import(source_file: String, save_path: String, options: Dictionary, r_platform_variants: Array[String], r_gen_files: Array[String]) -> Error:
	var file := FileAccess.open(source_file, FileAccess.READ)
	var line := file.get_line()

	var channels := line.split(",")
	if channels.size() != 3:
		return ERR_PARSE_ERROR

	var color := Color8(int(channels[0]), int(channels[1]), int(channels[2]))
	var material := StandardMaterial3D.new()

	if options.use_red_anyway:
		color = Color8(255, 0, 0)

	material.albedo_color = color

	return ResourceSaver.save(material, "%s.%s" % [save_path, _get_save_extension()])
