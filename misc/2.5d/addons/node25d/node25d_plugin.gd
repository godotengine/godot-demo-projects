tool
extends EditorPlugin

const MainPanel = preload("res://addons/node25d/main_screen/main_screen_25d.tscn")

var main_panel_instance

func _enter_tree():
	main_panel_instance = MainPanel.instance()
	main_panel_instance.get_child(1).editor_interface = get_editor_interface()

	# Add the main panel to the editor's main viewport.
	get_editor_interface().get_editor_viewport().add_child(main_panel_instance)

	# Hide the main panel.
	make_visible(false)
	# When this plugin node enters tree, add the custom types.
	add_custom_type("Node25D", "Node2D", preload("node_25d.gd"), preload("icons/node_25d_icon.png"))
	add_custom_type("YSort25D", "Node", preload("y_sort_25d.gd"), preload("icons/y_sort_25d_icon.png"))
	add_custom_type("ShadowMath25D", "KinematicBody", preload("shadow_math_25d.gd"), preload("icons/shadow_math_25d_icon.png"))


func _exit_tree():
	main_panel_instance.queue_free()
	# When the plugin node exits the tree, remove the custom types.
	remove_custom_type("ShadowMath25D")
	remove_custom_type("YSort25D")
	remove_custom_type("Node25D")


func has_main_screen():
	return true


func make_visible(visible):
	if visible:
		main_panel_instance.show()
	else:
		main_panel_instance.hide()


func get_plugin_name():
	return "2.5D"


func get_plugin_icon():
	return preload("res://addons/node25d/icons/viewport_25d.svg")
