@tool
extends EditorPlugin

const MainPanel = preload("res://addons/main_screen/main_panel.tscn")

var main_panel_instance

func _enter_tree():
	main_panel_instance = MainPanel.instantiate()
	# Add the main panel to the editor's main viewport.
	get_editor_interface().get_editor_main_screen().add_child(main_panel_instance)
	# Hide the main panel. Very much required.
	_make_visible(false)


func _exit_tree():
	if main_panel_instance:
		main_panel_instance.queue_free()


func _has_main_screen():
	return true


func _make_visible(visible):
	if main_panel_instance:
		main_panel_instance.visible = visible


# If your plugin doesn't handle any node types, you can remove this method.
func _handles(object):
	return is_instance_of(object, preload("res://addons/main_screen/handled_by_main_screen.gd"))


func _get_plugin_name():
	return "Main Screen Plugin"


func _get_plugin_icon():
	# Must return some kind of Texture2D for the icon.
	return get_editor_interface().get_base_control().get_theme_icon("Node", "EditorIcons")
