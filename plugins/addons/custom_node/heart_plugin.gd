@tool
extends EditorPlugin


func _enter_tree() -> void:
	# When this plugin node enters tree, add the custom type.
	var icon: Texture2D = preload("res://addons/custom_node/heart.png")
	add_custom_type("Heart", "Node2D", preload("res://addons/custom_node/heart.gd"), icon)


func _exit_tree() -> void:
	# When the plugin node exits the tree, remove the custom type.
	remove_custom_type("Heart")
