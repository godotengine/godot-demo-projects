# The word "silly" is used to make it obvious that the name is arbitrary.
@tool
extends Panel


var editor_interface: EditorInterface

@onready var albedo_color_picker: ColorPickerButton = $VBoxContainer/AlbedoColorPicker
@onready var metallic_slider: HSlider = $VBoxContainer/MetallicSlider
@onready var roughness_slider: HSlider = $VBoxContainer/RoughnessSlider

@onready var save_material_dialog: FileDialog = $SaveMaterialDialog
@onready var export_material_dialog: FileDialog = $ExportMaterialDialog
@onready var load_material_importer_dialog: FileDialog = $LoadMaterialImporterDialog
@onready var load_material_loader_dialog: FileDialog = $LoadMaterialLoaderDialog
@onready var import_material_directly_dialog: FileDialog = $ImportMaterialDirectlyDialog


func _ready() -> void:
	if not name.contains(" "):
		printerr("Warning: Material Creator dock doesn't have a space in its node name, so it will be displayed without any spacing.")
	save_material_dialog.current_path = "res://addons/material_creator/example/"
	save_material_dialog.current_file = "new_material.silly_mat_loadable"
	export_material_dialog.current_path = "res://addons/material_creator/example/"
	export_material_dialog.current_file = "new_material.silly_mat_importable"
	load_material_importer_dialog.current_path = "res://addons/material_creator/example/"
	load_material_loader_dialog.current_path = "res://addons/material_creator/example/"
	import_material_directly_dialog.current_path = ProjectSettings.globalize_path("res://addons/material_creator/example/")
	RenderingServer.canvas_item_set_clip(get_canvas_item(), true)


func _save_or_export_file(path: String) -> void:
	if path.is_empty():
		printerr("Material Creator: No path chosen for saving.")
		return
	# Ensure directory exists before trying to save to it.
	var dir: String = path.get_base_dir()
	if not DirAccess.dir_exists_absolute(dir):
		var err: Error = DirAccess.make_dir_recursive_absolute(dir)
		if err != OK:
			printerr("Material Creator: Can't create folder: %s (%s)" % [dir, error_string(err)])
			return
	var silly_mat: SillyMaterialResource = _create_silly_material_from_editor_values()
	var ext: String = path.get_extension().to_lower()
	var err: Error
	var is_in_project: bool = path.begins_with("res://") or path.begins_with("user://")
	if ext == "tres":
		err = ResourceSaver.save(silly_mat, path)
		if not is_in_project:
			printerr("Material Creator: Warning: When saving outside of the Godot project, "
					+ "prefer exporting instead. A Godot resource may not be functional "
					+ "without the context of its original project (ex: script paths).")
	elif ext == "silly_mat_loadable" and is_in_project:
		err = ResourceSaver.save(silly_mat, path)
	else:
		err = silly_mat.write_to_file(path)
	if err != OK:
		printerr("Material Creator: Failed to save to %s, reason: %s" % [path, error_string(err)])
	else:
		print("Material Creator: Successfully saved to ", path)
	# Inform the editor that files have changed on disk.
	var efs: EditorFileSystem = editor_interface.get_resource_filesystem()
	efs.scan()


func load_file_resource_loader(path: String) -> void:
	var loaded_file: Resource = ResourceLoader.load(path)
	if loaded_file == null:
		printerr("Material Creator: Failed to load file at %s" % path)
		return
	if loaded_file is SillyMaterialResource:
		edit_silly_material(loaded_file)
		return
	if loaded_file is StandardMaterial3D:
		edit_silly_material(SillyMaterialResource.from_material(loaded_file))
		return


func load_file_directly(path: String) -> void:
	var silly_mat := SillyMaterialResource.read_from_file(path)
	if silly_mat == null:
		printerr("Material Creator: Failed to directly load file at %s" % path)
	edit_silly_material(silly_mat)


func edit_silly_material(silly_mat: SillyMaterialResource) -> void:
	albedo_color_picker.color = silly_mat.albedo_color
	metallic_slider.value = silly_mat.metallic_strength
	roughness_slider.value = silly_mat.roughness_strength


func _create_silly_material_from_editor_values() -> SillyMaterialResource:
	var color: Color = albedo_color_picker.color
	var metallic: float = metallic_slider.value
	var roughness: float = roughness_slider.value
	var silly_res := SillyMaterialResource.new()
	silly_res.albedo_color = color
	silly_res.metallic_strength = metallic
	silly_res.roughness_strength = roughness
	return silly_res


func _apply_material_to_nodes(selected_nodes: Array[Node]) -> void:
	if selected_nodes.is_empty():
		printerr("Material Creator: Can't apply the material because there are no nodes selected!")
		return
	var new_material: StandardMaterial3D = _create_silly_material_from_editor_values().to_material()
	# Go through the selected nodes and see if they are MeshInstance3D nodes.
	# If they do, then call it to set the material to the silly material.
	var applied: bool = false
	for node in selected_nodes:
		if node is MeshInstance3D:
			node.set_surface_override_material(0, new_material)
			applied = true
	if applied:
		print("Material Creator: Applied material to selected MeshInstance3D nodes!")
	else:
		printerr("Material Creator: Can't apply the material because there are no MeshInstance3D nodes selected!")


func _on_apply_button_pressed() -> void:
	# Using the passed in editor interface, get the selected nodes in the editor.
	var editor_selection: EditorSelection = editor_interface.get_selection()
	var selected_nodes: Array[Node] = editor_selection.get_selected_nodes()
	_apply_material_to_nodes(selected_nodes)


func _on_save_button_pressed() -> void:
	save_material_dialog.popup_centered(save_material_dialog.min_size * EditorInterface.get_editor_scale())


func _on_export_button_pressed() -> void:
	export_material_dialog.popup_centered(export_material_dialog.min_size * EditorInterface.get_editor_scale())


func _on_load_button_importer_pressed() -> void:
	load_material_importer_dialog.popup_centered(load_material_importer_dialog.min_size * EditorInterface.get_editor_scale())


func _on_load_button_loader_pressed() -> void:
	load_material_loader_dialog.popup_centered(load_material_loader_dialog.min_size * EditorInterface.get_editor_scale())


func _on_import_button_directly_pressed() -> void:
	import_material_directly_dialog.popup_centered(import_material_directly_dialog.min_size * EditorInterface.get_editor_scale())
