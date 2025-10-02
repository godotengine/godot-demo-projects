@tool
extends Panel
# In this file, the word "silly" is used to make it obvious that the name is arbitrary.

var silly_material_resource = preload("res://addons/material_creator/material_resource.gd")
var editor_interface: EditorInterface


func _ready() -> void:
	# Connect all of the signals we'll need to save and load silly materials.
	$VBoxContainer/ApplyButton.pressed.connect(apply_pressed)
	$VBoxContainer/SaveButton.pressed.connect(save_pressed)
	$VBoxContainer/LoadButton.pressed.connect(load_pressed)
	$SaveMaterialDialog.file_selected.connect(save_file_selected)
	$LoadMaterialDialog.file_selected.connect(load_file_selected)
	RenderingServer.canvas_item_set_clip(get_canvas_item(), true)


func save_pressed() -> void:
	$SaveMaterialDialog.popup_centered_ratio()


func load_pressed() -> void:
	$LoadMaterialDialog.popup_centered_ratio()


func apply_pressed() -> void:
	# Using the passed in editor interface, get the selected nodes in the editor.
	var editor_selection: EditorSelection = editor_interface.get_selection()
	var selected_nodes := editor_selection.get_selected_nodes()
	if selected_nodes.is_empty():
		push_error("Material Creator: Can't apply the material, because there are no nodes selected!")

	var new_material: StandardMaterial3D = _silly_resource_from_values().make_material()
	# Go through the selected nodes and see if they have the "set_surface_override_material"
	# function (which only MeshInstance3D has by default). If they do, then set the material
	# to the silly material.
	for node in selected_nodes:
		if node.has_method("set_surface_override_material"):
			node.set_surface_override_material(0, new_material)


func save_file_selected(path: String) -> bool:
	var silly_resource: Variant = _silly_resource_from_values()
	# Make a file, store the silly material as a JSON string.
	var file := FileAccess.open(path, FileAccess.WRITE)
	file.store_string(silly_resource.make_json())

	return true


func load_file_selected(path: String) -> bool:
	var SpatialMaterial_Silly: StandardMaterial3D = null

	# Make a new silly resource (which in this case actually is a node)
	# and initialize it.
	var silly_resource: Variant = silly_material_resource.new()
	#silly_resource.init()

	# If the file exists, then open it.
	if FileAccess.file_exists(path):
		var file := FileAccess.open(path, FileAccess.READ)

		# Get the JSON string and convert it into a silly material.
		var json_dict_as_string := file.get_line()
		if json_dict_as_string != null:
			silly_resource.from_json(json_dict_as_string)
		else:
			return false

		$VBoxContainer/AlbedoColorPicker.color = silly_resource.albedo_color
		$VBoxContainer/MetallicSlider.value = silly_resource.metallic_strength
		$VBoxContainer/RoughnessSlider.value = silly_resource.roughness_strength

		# Return `true` to indicate success.
		return true

	# If the file does not exist, then return `false` to indicate failure.
	return false


func _silly_resource_from_values() -> Variant:
	# Get the values from the sliders and color picker.
	var color: Color = $VBoxContainer/AlbedoColorPicker.color
	var metallic: float = $VBoxContainer/MetallicSlider.value
	var roughness: float = $VBoxContainer/RoughnessSlider.value
	# Make a new silly resource (which in this case actually is a node) and initialize it.
	var silly_resource: Variant = silly_material_resource.new()
	#silly_resource.init()

	# Assign the values.
	silly_resource.albedo_color = color
	silly_resource.metallic_strength = metallic
	silly_resource.roughness_strength = roughness

	return silly_resource
