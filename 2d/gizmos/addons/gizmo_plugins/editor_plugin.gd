@tool
## This editor plugin registers the gizmo plugins we use for editing our
## custom nodes.
extends EditorPlugin

# We don't use class_name for editor classes to avoid polluting the 
# global namespace with editor-only classes. Therefore we use the
# "old fashioned" way to include a class. Note how preload can use
# relative paths, this makes it a nicer choice over load here.
const CircleGizmoPlugin = preload("circle_gizmo_plugin.gd")
const FlowerGizmoPlugin = preload("flower_gizmo_plugin.gd")

var _circle_gizmo_plugin:CircleGizmoPlugin
var _flower_gizmo_plugin:FlowerGizmoPlugin

## Registers the gizmo plugins with the editor.
func _enter_tree() -> void:
	_circle_gizmo_plugin = CircleGizmoPlugin.new()
	add_canvas_item_gizmo_plugin(_circle_gizmo_plugin)

	_flower_gizmo_plugin = FlowerGizmoPlugin.new()
	add_canvas_item_gizmo_plugin(_flower_gizmo_plugin)

## Unregisters the gizmo plugins from, the editor.
func _exit_tree() -> void:
	remove_canvas_item_gizmo_plugin(_circle_gizmo_plugin)
	remove_canvas_item_gizmo_plugin(_flower_gizmo_plugin)
