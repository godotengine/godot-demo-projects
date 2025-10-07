# A simple (and silly) material resource plugin. Allows you to make a really simple material
# from a custom dock, that you can save and load, and apply to selected MeshInstances.
#
# SPECIAL NOTE: This technically should be using EditorImportPlugin and EditorExportPlugin
# to handle the input and output of the silly material. However, currently you cannot export
# custom resources in Godot, so instead we're using JSON files instead.
#
# This example should be replaced when EditorImportPlugin and EditorExportPlugin are both
# fully working and you can save custom resources.

@tool
extends EditorPlugin

var io_material_dialog: Panel
var _loader: SillyMatFormatLoader
var _saver: SillyMatFormatSaver


func _enter_tree() -> void:
	_loader = SillyMatFormatLoader.new()
	_saver = SillyMatFormatSaver.new()
	ResourceLoader.add_resource_format_loader(_loader)
	ResourceSaver.add_resource_format_saver(_saver)

	io_material_dialog = preload("res://addons/material_creator/material_dock.tscn").instantiate()
	io_material_dialog.editor_interface = get_editor_interface()
	add_control_to_dock(DOCK_SLOT_LEFT_UL, io_material_dialog)


func _exit_tree() -> void:
	remove_control_from_docks(io_material_dialog)

	if _loader:
		ResourceLoader.remove_resource_format_loader(_loader)
		_loader = null
	if _saver:
		ResourceSaver.remove_resource_format_saver(_saver)
		_saver = null
