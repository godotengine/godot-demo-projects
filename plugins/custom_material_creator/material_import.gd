# A simple (and silly) material resource plugin. Allows you to make a really simple material
# from a custom dock, that you can save and load, and apply to selected MeshInstances.
#
# SPECIAL NOTE: This technically should be using EditorImportPlugin and EditorExportPlugin
# to handle the input and output of the silly material. However, currently you cannot export
# custom resources in Godot, so instead we're using JSON files instead.
# |
# This example should be replaced when EditorImportPlugin and EditorExportPlugin are both
# fully working and you can save custom resources.

tool
extends EditorPlugin

var io_material_dialog;

func _enter_tree():
	
	io_material_dialog = preload("res://addons/custom_import_plugin/Custom_material_dock.tscn").instance()
	io_material_dialog.editor_interface = get_editor_interface();
	
	add_control_to_dock(DOCK_SLOT_LEFT_UL, io_material_dialog)

func _exit_tree():
	remove_control_from_docks(io_material_dialog)
