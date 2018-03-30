tool
extends EditorImportPlugin

enum Presets { PRESET_DEFAULT }

func get_importer_name():
	return "demos.sillymaterial"

func get_visible_name():
	return "Silly Material"

func get_recognized_extensions():
	return ["mtxt"]

func get_save_extension():
	return "res"

func get_resource_type():
	return "Material"

func get_preset_count():
	return 1

func get_preset_name(preset):
	match preset:
		PRESET_DEFAULT: return "Default"
		_ : return "Unknown"

func get_import_options(preset):
	match preset:
		PRESET_DEFAULT:
			return [{
					"name": "use_red_anyway",
					"default_value": false
					}]
		_: return []

func get_option_visibility(option, options):
	return true

func import(source_file, save_path, options, r_platform_variants, r_gen_files):
	var file = File.new()
	var err = file.open(source_file, File.READ)
	if err != OK:
		return err

	var line = file.get_line()

	file.close()

	var channels = line.split(",")
	if channels.size() != 3:
		return ERR_PARSE_ERROR

	var color = Color8(int(channels[0]), int(channels[1]), int(channels[2]))
	var material = SpatialMaterial.new()

	if options.use_red_anyway:
		color = Color8(255, 0, 0)

	material.albedo_color = color

	return ResourceSaver.save("%s.%s" % [save_path, get_save_extension()], material)
