@tool
extends EditorImportPlugin

enum Presets { PRESET_DEFAULT }

func _get_importer_name():
	return "demos.sillymaterial"


func _get_visible_name():
	return "Silly Material"


func _get_recognized_extensions():
	return ["mtxt"]


func _get_save_extension():
	return "res"


func _get_resource_type():
	return "Material"


func _get_preset_count():
	return Presets.size()


func _get_preset_name(preset):
	match preset:
		Presets.PRESET_DEFAULT: return "Default"
		_: return "Unknown"


func _get_import_options(_path, preset):
	match preset:
		Presets.PRESET_DEFAULT:
			return [{
					"name": "use_red_anyway",
					"default_value": false
					}]
		_: return []


func _get_import_order():
	return ResourceImporter.IMPORT_ORDER_DEFAULT


func _get_option_visibility(path, option, options):
	return true


func _import(source_file, save_path, options, r_platform_variants, r_gen_files):
	var file = FileAccess.open(source_file, FileAccess.READ)
	var line = file.get_line()

	var channels = line.split(",")
	if channels.size() != 3:
		return ERR_PARSE_ERROR

	var color = Color8(int(channels[0]), int(channels[1]), int(channels[2]))
	var material = StandardMaterial3D.new()

	if options.use_red_anyway:
		color = Color8(255, 0, 0)

	material.albedo_color = color

	return ResourceSaver.save(material, "%s.%s" % [save_path, _get_save_extension()])
