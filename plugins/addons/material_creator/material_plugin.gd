## A simple (and silly) material resource plugin. Allows you to make a really
## simple material from a custom dock, which can be applied to meshes,
## saved to files, loaded from files, imported from files, and more.
##
## See the documentation in the `README.md` file for more information,
## and also the documentation in each class (Ctrl+Click on these in Godot):
## - SillyMaterialResource
## - ImportSillyMatAsSillyMaterialResource
## - ImportSillyMatAsStandardMaterial3D
## - SillyMatFormatLoader
## - SillyMatFormatSaver
@tool
extends EditorPlugin


var _material_creator_dock: Panel
var _silly_mat_loader := SillyMatFormatLoader.new()
var _silly_mat_saver := SillyMatFormatSaver.new()
var _import_as_silly_mat_res := ImportSillyMatAsSillyMaterialResource.new()
var _import_as_standard_mat := ImportSillyMatAsStandardMaterial3D.new()


func _enter_tree() -> void:
	# Set up the loader and saver.
	ResourceLoader.add_resource_format_loader(_silly_mat_loader)
	ResourceSaver.add_resource_format_saver(_silly_mat_saver)
	# Set up the importers.
	add_import_plugin(_import_as_silly_mat_res)
	add_import_plugin(_import_as_standard_mat)
	# Set up the silly material creator dock.
	const dock_scene: PackedScene = preload("res://addons/material_creator/editor/material_dock.tscn")
	_material_creator_dock = dock_scene.instantiate()
	_material_creator_dock.editor_interface = get_editor_interface()
	var dock_scale: float = EditorInterface.get_editor_scale() * 0.85
	_material_creator_dock.custom_minimum_size *= dock_scale
	for child in _material_creator_dock.find_children("*", "Control"):
		child.custom_minimum_size *= dock_scale
	add_control_to_dock(DOCK_SLOT_LEFT_UL, _material_creator_dock)


func _exit_tree() -> void:
	remove_control_from_docks(_material_creator_dock)
	ResourceLoader.remove_resource_format_loader(_silly_mat_loader)
	ResourceSaver.remove_resource_format_saver(_silly_mat_saver)
	remove_import_plugin(_import_as_silly_mat_res)
	remove_import_plugin(_import_as_standard_mat)
