@tool
extends EditorPlugin

const MainPanel = preload("res://addons/node25d/main_screen/main_screen_25d.tscn")

var main_panel_instance: VBoxContainer


func _enter_tree() -> void:
	main_panel_instance = MainPanel.instantiate()
	main_panel_instance.get_child(1).editor_interface = get_editor_interface()

	# Add the main panel to the editor's main viewport.
	EditorInterface.get_editor_main_screen().add_child(main_panel_instance)

	# Hide the main panel.
	_make_visible(false)
	# When this plugin node enters tree, add the custom types.
	add_custom_type("Node25D", "Node2D", preload("node_25d.gd"), preload("icons/node_25d_icon.png"))
	add_custom_type("YSort25D", "Node", preload("y_sort_25d.gd"), preload("icons/y_sort_25d_icon.png"))
	add_custom_type("ShadowMath25D", "CharacterBody3D", preload("shadow_math_25d.gd"), preload("icons/shadow_math_25d_icon.png"))


func _exit_tree() -> void:
	if main_panel_instance:
		main_panel_instance.queue_free()
	# When the plugin node exits the tree, remove the custom types.
	remove_custom_type("ShadowMath25D")
	remove_custom_type("YSort25D")
	remove_custom_type("Node25D")


func _has_main_screen() -> bool:
	return true


func _make_visible(visible: bool) -> void:
	if main_panel_instance:
		if visible:
			main_panel_instance.show()
		else:
			main_panel_instance.hide()


func _get_plugin_name() -> String:
	return "2.5D"


func _get_plugin_icon() -> Texture2D:
	return preload("res://addons/node25d/icons/viewport_25d.svg")


func _handles(obj: Object) -> bool:
	return obj is Node25D
