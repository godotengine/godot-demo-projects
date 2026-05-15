@tool
extends EditorPlugin


func _enter_tree() -> void:
	# When this plugin node enters tree, add the custom type.
	# The icon parameter is optional and omitted here for simplicity.
	add_custom_type("Stats", "Resource", preload("res://addons/custom_resource/stats.gd"), null)


func _exit_tree() -> void:
	# When the plugin node exits the tree, remove the custom type.
	remove_custom_type("Stats")
