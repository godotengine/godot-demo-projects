@tool
extends EditorImportPlugin
class_name BSPImporterPlugin

# Unfortunately, usinge resources in the import settings can cause the project to fail to load due 
# to a bug in the config file reader: https://github.com/godotengine/godot/issues/83316
# Related issues: https://github.com/godotengine/godot/issues/99267 and https://github.com/godotengine/godot-proposals/issues/8350
const USE_PRESET_RESOURCE := false
var last_selected_file := "" # used for differenciating in stuffwha

func _get_importer_name():
	return "bsp"

func _get_visible_name():
	match last_selected_file.get_extension().to_lower():
		"bsp": return "Quake BSP"
		"wad": return "WAD Container"

func _get_recognized_extensions():
	return ["bsp", "wad"]


func _get_priority():
	return 1.0


func _get_import_order():
	return 0


func _get_save_extension():
	return "scn"


func _get_resource_type():
	return "PackedScene"


func _can_import_threaded():
	return false


enum Presets { DEFAULT }


func _get_preset_count():
	return Presets.size()


func _get_preset_name(preset):
	match preset:
		Presets.DEFAULT:
			return "Default"
		_:
			return "Unknown"


func _get_import_options(path : String, preset_index : int):
	last_selected_file = path
	match path.get_extension().to_lower():
		"bsp":
			print("get options ", path, " index: ", preset_index)
			var import_path = str(path, ".import")
			var import_config := ConfigFile.new()
			var bsp_preset : BSPImportPreset
			if (USE_PRESET_RESOURCE):
				# Grab the old settings and store them in a preset.
				if (import_config.load(import_path) == OK):
					# If it has a preset, it's a newer import file.  If not, convert the data into a preset
					if (!import_config.has_section_key("params", "preset")):
						bsp_preset = BSPImportPreset.new()
						bsp_preset.unit_scale = 1.0 / import_config.get_value("params", "inverse_scale_factor", 32.0)
						bsp_preset.ignored_flags = import_config.get_value("params", "ignored_flags", PackedInt64Array())
						bsp_preset.generate_texture_materials = import_config.get_value("params", "generate_texture_materials", true)
						bsp_preset.save_separate_materials = import_config.get_value("params", "save_separate_materials", true)
						bsp_preset.material_path_pattern = import_config.get_value("params", "material_path_pattern", "res://materials/{texture_name}_material.tres")
						bsp_preset.texture_material_rename = import_config.get_value("params", "texture_material_rename", {})
						bsp_preset.texture_path_pattern = import_config.get_value("params", "texture_path_pattern", "res://textures/{texture_name}.png")
						bsp_preset.texture_emission_path_pattern = import_config.get_value("params", "texture_emission_path_pattern", "res://textures/{texture_name}_emission.png")
						bsp_preset.texture_path_remap = import_config.get_value("params", "texture_path_remap", {})
						bsp_preset.transparent_texture_prefix = import_config.get_value("params", "transparent_texture_prefix", "{")
						bsp_preset.texture_palette_path = import_config.get_value("params", "texture_palette_path", "res://textures/palette.lmp")
						bsp_preset.fullbright_range = import_config.get_value("params", "fullbright_range", [224,255])
						bsp_preset.overwrite_existing_textures = import_config.get_value("params", "overwrite_existing_textures", false)
						bsp_preset.water_scene_template = load(import_config.get_value("params", "water_scene_template", "res://addons/bsp_importer/examples/water_example_template.tscn"))
						bsp_preset.slime_scene_template = load(import_config.get_value("params", "slime_scene_template", "res://addons/bsp_importer/examples/slime_example_template.tscn"))
						bsp_preset.lava_scene_template = load(import_config.get_value("params", "lava_scene_template", "res://addons/bsp_importer/examples/lava_example_template.tscn"))
						bsp_preset.entity_path_pattern = import_config.get_value("params", "entity_path_pattern", "res://entities/{classname}.tscn")
						bsp_preset.entity_remap = import_config.get_value("params", "entity_remap", { &"trigger_example" : preload("res://addons/bsp_importer/examples/trigger_example.tscn") })
						bsp_preset.entity_offsets_quake_units = import_config.get_value("params", "entity_offsets_quake_units", {})
						bsp_preset.import_lights = import_config.get_value("params", "import_lights", true)
						bsp_preset.generate_occlusion_culling = import_config.get_value("params", "generate_occlusion_culling", true)
						bsp_preset.culling_textures_exclude = import_config.get_value("params", "culling_textures_exclude", [])
						bsp_preset.separate_mesh_on_grid = import_config.get_value("params", "separate_mesh_on_grid", false)
						bsp_preset.mesh_separation_grid_size = import_config.get_value("params", "mesh_separation_grid_size", 256.0)
						bsp_preset.use_triangle_collision = import_config.get_value("params", "use_triangle_collision", false)
						bsp_preset.ignore_missing_entities = import_config.get_value("params", "ignore_missing_entities", false)
						bsp_preset.post_import_script = import_config.get_value("params", "post_import_script", "")

				if (!bsp_preset):
					bsp_preset = preload("res://addons/bsp_importer/examples/preset_example.tres")

				match preset_index:
					Presets.DEFAULT:
						return [ {
							"name" : "preset",
							"default_value" : bsp_preset,
							"property_hint" : PROPERTY_HINT_RESOURCE_TYPE,
							"hint_string" : "BSPImportPreset"
						} ]
					_:
						return []
			else: # No preset resource -- use this until the issues in the engine are resolved.
				match preset_index:
					Presets.DEFAULT:
						return [{
							"name" : "inverse_scale_factor",
							"default_value" : 32.0
						},
						{
							"name" : "ignored_flags",
							"default_value" : PackedInt64Array()
						},
						{
							"name" : "include_sky_surfaces",
							"default_value" : true
						},
						{
							"name" : "generate_texture_materials",
							"default_value" : true
						},
						{
							"name" : "save_separate_materials",
							"default_value" : true
						},
						{
							"name" : "overwrite_existing_materials",
							"default_value" : false
						},
						{
							"name" : "material_path_pattern",
							"default_value" : "res://materials/{texture_name}_material.tres"
						},
						{
							"name" : "texture_material_rename",
							"default_value" : { "texture_name1_example" : "res://material/texture_name1_material.tres" }
						},
						{
							"name" : "texture_path_pattern",
							"default_value" : "res://textures/{texture_name}.png"
						},
						{
							"name" : "texture_emission_path_pattern",
							"default_value" : "res://textures/{texture_name}_emission.png"
						},
						{
							"name" : "texture_path_remap",
							"default_value" : { "texture_name1_example" : "res://textures/texture_name1.png" }
						},
						{
							"name" : "transparent_texture_prefix",
							"default_value" : "{"
						},
						{
							"name" : "texture_palette_path",
							"default_value" : "res://textures/palette.lmp"
						},
						{
							"name" : "fullbright_range",
							"default_value" : [224, 255] as PackedInt32Array
						},
						{
							"name" : "overwrite_existing_textures",
							"default_value" : false
						},
						{
							"name" : "water_scene_template",
							"default_value" : "res://addons/bsp_importer/examples/water_example_template.tscn"
						},
						{
							"name" : "slime_scene_template",
							"default_value" : "res://addons/bsp_importer/examples/slime_example_template.tscn"
						},
						{
							"name" : "lava_scene_template",
							"default_value" : "res://addons/bsp_importer/examples/lava_example_template.tscn"
						},
						{
							"name" : "entity_path_pattern",
							"default_value" : "res://entities/{classname}.tscn"
						},
						{
							"name" : "entity_remap",
							"default_value" : { &"trigger_example" : "res://triggers/trigger_example.tres" }
						},
						{
							"name" : "entity_offsets_quake_units",
							"default_value" : { &"example_offset_entity" : Vector3(16, 16, 0) }
						},
						{
							"name" : "import_lights",
							"default_value" : true
						},
						{
							"name" : "light_brightness_scale",
							"default_value" : 16.0
						},
						{
							"name" : "generate_occlusion_culling",
							"default_value" : true
						},
						# This doesn't work properly, yet.
						#{
							### Generates an optimized mesh for shadow rendering (single material, merged verts)
							#"name" : "generate_shadow_mesh",
							#"default_value" : true
						#},
						{
							"name" : "culling_textures_exclude",
							"default_value" : [] as Array[StringName]
						},
						{
							"name" : "use_triangle_collision",
							"default_value" : false
						},
						{
							"name" : "separate_mesh_on_grid",
							"default_value" : false
						},
						{
							"name" : "mesh_separation_grid_size",
							"default_value" : 256.0
						},
						{
							"name" : "ignore_missing_entities",
							"default_value" : false
						},
						{
							"name" : "post_import_script",
							"default_value" : ""
						}]
					_:
						return []


func _get_option_visibility(_option, _options, _unknown_dictionary):
	return true


func _import(source_file : String, save_path : String, options : Dictionary, r_platform_variants, r_gen_files):
	match source_file.get_extension().to_lower():
		"wad":
			var reader = WADReader.new()
			reader.read_wad(source_file)
			reader.read_directory(source_file)
			reader.name = source_file.get_file()
			
			var packed_scene := PackedScene.new()
			var err := packed_scene.pack(reader)
			if err == OK: 
				
				var r = ResourceSaver.save(packed_scene, "%s.%s" % [save_path, _get_save_extension()])
				
				reader.free()
				return r
		
		"bsp":
			var bsp_reader := BSPReader.new()
			var preset : BSPImportPreset
			if (USE_PRESET_RESOURCE):
				preset = options.get("preset", null)
			if (preset):
				print("Importing BSP from preset.")
				bsp_reader.unit_scale = 1.0 / preset.inverse_scale_factor
				bsp_reader.ignored_flags = preset.ignored_flags
				bsp_reader.generate_texture_materials = preset.generate_texture_materials
				bsp_reader.save_separate_materials = preset.save_separate_materials
				bsp_reader.overwrite_existing_materials = preset.overwrite_existing_materials
				bsp_reader.material_path_pattern = preset.material_path_pattern
				bsp_reader.texture_material_rename = preset.texture_material_rename
				bsp_reader.texture_path_pattern = preset.texture_path_pattern
				bsp_reader.texture_emission_path_pattern = preset.texture_emission_path_pattern
				bsp_reader.texture_path_remap = preset.texture_path_remap
				bsp_reader.transparent_texture_prefix = preset.transparent_texture_prefix
				bsp_reader.texture_palette_path = preset.texture_palette_path
				bsp_reader.fullbright_range = preset.fullbright_range
				bsp_reader.overwrite_existing_textures = preset.overwrite_existing_textures
				bsp_reader.water_template = preset.water_scene_template
				bsp_reader.slime_template = preset.slime_scene_template
				bsp_reader.lava_template = preset.lava_scene_template
				bsp_reader.entity_path_pattern = preset.entity_path_pattern
				bsp_reader.entity_remap = preset.entity_remap
				bsp_reader.entity_offsets_quake_units = preset.entity_offsets_quake_units
				bsp_reader.import_lights = preset.import_lights
				bsp_reader.light_brightness_scale = preset.light_brightness_scale
				bsp_reader.generate_occlusion_culling = preset.generate_occlusion_culling
				bsp_reader.culling_textures_exclude = preset.culling_textures_exclude
				#bsp_reader.generate_shadow_mesh = preset.generate_shadow_mesh # Not fully implemented, yet
				bsp_reader.use_triangle_collision = preset.use_triangle_collision
				bsp_reader.separate_mesh_on_grid = preset.separate_mesh_on_grid
				bsp_reader.mesh_separation_grid_size = preset.mesh_separation_grid_size
				bsp_reader.ignore_missing_entities = preset.ignore_missing_entities
				bsp_reader.post_import_script_path = preset.post_import_script
			else:
				print("Importing BSP from import settings.")
				bsp_reader.unit_scale = 1.0 / options.inverse_scale_factor
				bsp_reader.ignored_flags = options.ignored_flags
				bsp_reader.include_sky_surfaces = options.include_sky_surfaces
				bsp_reader.generate_texture_materials = options.generate_texture_materials
				bsp_reader.save_separate_materials = options.save_separate_materials
				bsp_reader.overwrite_existing_materials = options.overwrite_existing_materials
				bsp_reader.material_path_pattern = options.material_path_pattern
				bsp_reader.texture_material_rename = options.texture_material_rename
				bsp_reader.texture_path_pattern = options.texture_path_pattern
				bsp_reader.texture_emission_path_pattern = options.texture_emission_path_pattern
				bsp_reader.texture_path_remap = options.texture_path_remap
				bsp_reader.transparent_texture_prefix = options.transparent_texture_prefix
				bsp_reader.texture_palette_path = options.texture_palette_path
				bsp_reader.fullbright_range = options.fullbright_range
				bsp_reader.overwrite_existing_textures = options.overwrite_existing_textures
				bsp_reader.water_template = load(options.water_scene_template)
				bsp_reader.slime_template = load(options.slime_scene_template)
				bsp_reader.lava_template = load(options.lava_scene_template)
				bsp_reader.entity_path_pattern = options.entity_path_pattern
				bsp_reader.entity_remap = options.entity_remap
				bsp_reader.entity_offsets_quake_units = options.entity_offsets_quake_units
				bsp_reader.import_lights = options.import_lights
				bsp_reader.light_brightness_scale = options.light_brightness_scale
				bsp_reader.generate_occlusion_culling = options.generate_occlusion_culling
				bsp_reader.culling_textures_exclude = options.culling_textures_exclude
				#bsp_reader.generate_shadow_mesh = options.generate_shadow_mesh # Not fully implemented yet.
				bsp_reader.use_triangle_collision = options.use_triangle_collision
				bsp_reader.separate_mesh_on_grid = options.separate_mesh_on_grid
				bsp_reader.mesh_separation_grid_size = options.mesh_separation_grid_size
				bsp_reader.ignore_missing_entities = options.ignore_missing_entities
				bsp_reader.post_import_script_path = options.post_import_script

			var bsp_scene := bsp_reader.read_bsp(source_file)
			if (!bsp_scene):
				return bsp_reader.error
			for wad in bsp_reader.wad_paths: wad.free()
			bsp_reader.wad_paths.clear()
			var packed_scene := PackedScene.new()
			var err := packed_scene.pack(bsp_scene)
			if (err):
				print("Failed to pack scene: ", err)
				return err
			
			print("Saving to %s.%s" % [save_path, _get_save_extension()])
			var r = ResourceSaver.save(packed_scene, "%s.%s" % [save_path, _get_save_extension()])
			bsp_reader.free()
			return r
