extends Resource

class_name BSPImportPreset

## Number of Quake units per meter
@export var inverse_scale_factor := 32.0
## Flags the BSP Reader will ignore when generating geometry (Quake 2 Only)
@export var ignored_flags : PackedInt64Array = []
## If true, automatically generate materials from the textures.
@export var generate_texture_materials := true
## {texture_name} will be replaced by the texture name in the BSP file.
@export var material_path_pattern := "res://materials/{texture_name}_material.tres"
## Optional texture name to material remapping dictionary
@export var texture_material_rename := { &"texture_name1_example" : "res://material/texture_name1_material.tres" }
## Will write the material and texture files generated from the BSP file.
@export var save_separate_materials := true
## Generate a new matertial to replace existing one (useful if you update palette or textures compiled into BSP file).
@export var overwrite_existing_materials := false
## {texture_name} will be replaced by the texture name in the BSP file.
@export var texture_path_pattern := "res://textures/{texture_name}.png"
## {texture_name} will be replaced by the texture name in the BSP file.
@export var texture_emission_path_pattern := "res://textures/{texture_name}_emission.png"
## Optional texture name to material remapping dictionary
@export var texture_path_remap := { &"texture_name1_example" : "res://textures/texture_name1_example.png" }
## "{" is the default transparency texture indicator for Quake.  This will be stripped off the name and allow the texture to be used as a transparent surface.
@export var transparent_texture_prefix := "{"
## Palette .lmp file used when loading paletted textures.
@export var palette_palette_path := "res://textures/palette.lmp"
## Range of colors that willl be fullbright (emission).  Usually the last 32 colors.
@export var fullbright_range : PackedInt32Array = [224, 255]
## Will overwrite texture png files with the ones loaded from the BSP File.  Be careful with this!  Useful if you need to change the palette
@export var overwrite_existing_textures := false
## Water brushes from the BSP file will be replaced with this scene.  It should have an Area3D as the root.  Brush collision will be added as children.
@export var water_scene_template : PackedScene = preload("res://addons/bsp_importer/examples/water_example_template.tscn")
## Slime brushes from the BSP file will be replaced with this scene.  It should have an Area3D as the root.  Brush collision will be added as children.
@export var slime_scene_template : PackedScene = preload("res://addons/bsp_importer/examples/slime_example_template.tscn")
## Lava brushes from the BSP file will be replaced with this scene.  It should have an Area3D as the root.  Brush collision will be added as children.
@export var lava_scene_template : PackedScene = preload("res://addons/bsp_importer/examples/lava_example_template.tscn")
## Entities from the BSP file will use this scene, with {classname} replaced by the the class name string.  Use the entity remap if you want to map to specific scenes with different instead.  Brush entities should have a CharacterBody3D (or some other body) as the root.  Collisions from brushes will be added as children.
@export var entity_path_pattern := "res://entities/{classname}.tscn"
## Remaps an entity classname to a scene.  Brush entities should have a CharacterBody3D (or some other body) as the root.  Collisions from brushes will be added as children.
@export var entity_remap := { &"trigger_example" : preload("res://addons/bsp_importer/examples/trigger_example.tscn") }
## Some entities, such as health packs, are not centered, or you might need to offset them with this classname to vector3 offset dictionary.  Uses Quake units.
@export var entity_offsets_quake_units := { &"example_offset_entity_classname" : Vector3(16, 16, 0) }
## If true, light entities will import as omnilights.
@export var import_lights := true
## Light Brightness Scale
@export var light_brightness_scale := 16.0
## If true, will generate an occlusion mesh from the worldspawn to help cull out lights and objects behind walls.
@export var generate_occlusion_culling := true
## List of textures to exclude from the occlusion culling mesh.  Anything with transparency (grates, fences, etc) should be added here.
@export var culling_textures_exclude : Array[StringName] = []
#@export var generate_shadow_mesh := true # This doesn't work properly, yet.
## Break the world down into chunks based on a grid size.  This was an experiment to try to improve performance by culling out other rooms but seemed to perform worse, so I'd recommend leaving it off.
@export var separate_mesh_on_grid := false
## Size of grid chunks
@export var mesh_separation_grid_size := 256.0
## If true, use triangle collision from the visual geometry instead of convex brush collisions.  Faster to import, but usually slower for the physics performance.
@export var use_triangle_collision := false
## If true, the error message when importing a missing entity will not be printed.
@export var ignore_missing_entities := false
## Script to execute after importing for any custom post-import cleanup.
@export_file("*.gd") var post_import_script := ""
