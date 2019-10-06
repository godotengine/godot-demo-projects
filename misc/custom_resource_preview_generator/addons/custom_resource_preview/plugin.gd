tool
extends EditorPlugin

var res_preview_generator = preload("res://addons/custom_resource_preview/res_preview_generator.gd").new()

func _enter_tree():
	# We get the editor's resource previewer
	var prev = get_editor_interface().get_resource_previewer()
	# And we add our own generator to it when the plugin is loaded
	prev.add_preview_generator(res_preview_generator)
	
func _exit_tree():
	# We get the editor's resource previewer
	var prev = get_editor_interface().get_resource_previewer()
	# And we remove our own generator from it when the plugin is unloaded
	prev.remove_preview_generator(res_preview_generator)
