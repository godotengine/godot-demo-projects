@tool
extends Panel
# In this file, the word "silly" is used to make it obvious that the name is arbitrary.

var silly_material_resource := preload("res://addons/material_creator/material_resource.gd")
var editor_interface: EditorInterface


func _ready() -> void:
	# Connect all of the signals we'll need to save and load silly materials.
	$VBoxContainer/ApplyButton.pressed.connect(apply_pressed)
	$VBoxContainer/SaveButton.pressed.connect(save_pressed)
	$VBoxContainer/LoadButton.pressed.connect(load_pressed)

	$SaveMaterialDialog.file_mode = FileDialog.FILE_MODE_SAVE_FILE
	$SaveMaterialDialog.access = FileDialog.ACCESS_RESOURCES
	$SaveMaterialDialog.current_dir = "res://materials"
	$SaveMaterialDialog.current_file = "new_material.silly_mat"
	$SaveMaterialDialog.filters = PackedStringArray([
		"*.silly_mat ; Silly Material (resource)",
		"*.tres ; Godot Resource (resource)",
		"*.mtxt ; Silly Material (source)"
	])
	$SaveMaterialDialog.confirmed.connect(_on_save_confirmed)

	$LoadMaterialDialog.access = FileDialog.ACCESS_RESOURCES
	$LoadMaterialDialog.filters = PackedStringArray([
		"*.silly_mat ; Silly Material (resource)",
		"*.tres ; Godot Resource (resource)",
		"*.mtxt ; Silly Material (source)"
	])
	$LoadMaterialDialog.file_selected.connect(load_file_selected)

	RenderingServer.canvas_item_set_clip(get_canvas_item(), true)


func save_pressed() -> void:
	$SaveMaterialDialog.popup_centered_ratio()


func load_pressed() -> void:
	$LoadMaterialDialog.popup_centered_ratio()


func _on_save_confirmed() -> void:
	var path = $SaveMaterialDialog.get_current_path()
	if path.is_empty():
		push_error("Material Creator: No path chosen for saving.")
		return

	# If user typed no extension, default to .silly_mat (resource path).
	if not path.get_file().contains("."):
		path += ".silly_mat"

	var ext = path.get_extension().to_lower()

	# Ensure directory exists under res:// when saving inside project.
	var dir = path.get_base_dir()
	if path.begins_with("res://") and not DirAccess.dir_exists_absolute(dir):
		var mk := DirAccess.make_dir_recursive_absolute(dir)
		if mk != OK:
			push_error("Material Creator: Can't create folder: %s (%s)" % [dir, error_string(mk)])
			return

	var res: Resource = _silly_resource_from_values()

	match ext:
		"mtxt":
			# Write SOURCE file (no ResourceSaver, works anywhere).
			var ok := _write_source_silly(path, res)
			if not ok:
				push_error("Material Creator: Failed to write source .mtxt at %s" % path)
			else:
				print("Material Creator: Wrote source to ", path)
		"silly_mat", "tres":
			# Save RESOURCE (requires your custom saver for .silly_mat).
			res.resource_path = path
			var err := ResourceSaver.save(res, path)
			if err != OK:
				push_error("Material Creator: Failed to save resource: %s (%s)" % [path, error_string(err)])
			else:
				print("Material Creator: Saved resource to ", path)
		_:
			push_error("Material Creator: Unsupported extension: ." + ext)


func apply_pressed() -> void:
	# Using the passed in editor interface, get the selected nodes in the editor.
	var editor_selection: EditorSelection = editor_interface.get_selection()
	var selected_nodes := editor_selection.get_selected_nodes()
	if selected_nodes.is_empty():
		push_error("Material Creator: Can't apply the material, because there are no nodes selected!")
		return

	var new_material: StandardMaterial3D = _silly_resource_from_values().make_material()
	# Go through the selected nodes and see if they have the "set_surface_override_material"
	# function (which only MeshInstance3D has by default). If they do, then set the material
	# to the silly material.
	for node in selected_nodes:
		if node.has_method("set_surface_override_material"):
			node.set_surface_override_material(0, new_material)


func load_file_selected(path: String) -> bool:
	var ext := path.get_extension().to_lower()

	if ext == "mtxt":
		# Load SOURCE by manual parse (works inside/outside res://)
		var loaded := _read_source_silly(path)
		if loaded == null:
			push_error("Material Creator: Failed to parse source at %s" % path)
			return false
		$VBoxContainer/AlbedoColorPicker.color = loaded.albedo_color
		$VBoxContainer/MetallicSlider.value = loaded.metallic_strength
		$VBoxContainer/RoughnessSlider.value = loaded.roughness_strength
		return true
	else:
		# Load RESOURCE via ResourceLoader (silly_mat via your loader, tres via built-in)
		var silly_resource: Resource = ResourceLoader.load(path)
		if silly_resource == null:
			push_error("Material Creator: Failed to load resource at %s" % path)
			return false
		$VBoxContainer/AlbedoColorPicker.color = silly_resource.albedo_color
		$VBoxContainer/MetallicSlider.value = silly_resource.metallic_strength
		$VBoxContainer/RoughnessSlider.value = silly_resource.roughness_strength
		return true


func _silly_resource_from_values() -> Resource:
	var color: Color = $VBoxContainer/AlbedoColorPicker.color
	var metallic: float = $VBoxContainer/MetallicSlider.value
	var roughness: float = $VBoxContainer/RoughnessSlider.value
	var silly_res: Resource = silly_material_resource.new()
	silly_res.albedo_color = color
	silly_res.metallic_strength = metallic
	silly_res.roughness_strength = roughness
	return silly_res

# ---------------------------------------------------------------
# Source (.mtxt) helpers.
# ---------------------------------------------------------------

func _write_source_silly(path: String, res: Resource) -> bool:
	var mat_file := FileAccess.open(path, FileAccess.WRITE)
	if mat_file == null:
		return false
	mat_file.store_line("SILLY_MAT v1")
	mat_file.store_line(res.albedo_color.to_html(true)) # RGBA hex
	mat_file.store_line(str(res.metallic_strength))
	mat_file.store_line(str(res.roughness_strength))
	return true


func _read_source_silly(path: String) -> Resource:
	var mat_file := FileAccess.open(path, FileAccess.READ)
	if mat_file == null:
		return null
	var header := mat_file.get_line()
	if not header.begins_with("SILLY_MAT"):
		return null
	var mat_res := silly_material_resource.new()
	mat_res.albedo_color = Color(mat_file.get_line()) # from hex string
	mat_res.metallic_strength = float(mat_file.get_line())
	mat_res.roughness_strength = float(mat_file.get_line())
	return mat_res
