# This is the gizmo plugin that provides editor support for our Circle node.
# We deliberately do not use the class_name declaration here to avoid polluting the 
# global namespace with editor-only classes.
@tool
extends EditorCanvasItemGizmoPlugin


## This is the entry point into the gizmo system. We first need to tell the editor 
## whether or not this plugin will support a specific node. This plugin only supports 
## circle nodes, so we only return true if the given node is a circle node.
func _has_gizmo(for_canvas_item: CanvasItem) -> bool:
	return for_canvas_item is Circle


## This function should return the name of the gizmo. This is used in the gizmo menu in the 
## 2D editor to allow the user to show and hide the gizmo(s) created by this plugin.
func _get_gizmo_name() -> String:
	return "Circle"

## This function tells the editor whether this node has a bounding rectangle. 
## If this returns true, then the editor will draw a boundary around the node and also provide 
## scaling handles.
func _edit_use_rect(_gizmo: EditorCanvasItemGizmo) -> bool:
	return true

## This function tells the editor what the bounding rectangle of the node is. 
## This is only called if _edit_use_rect returns true.
func _edit_get_rect(gizmo: EditorCanvasItemGizmo) -> Rect2:
	# First we get the node we're editing
	var circle:Circle = gizmo.get_canvas_item()
	
	# This is a centered circle, so the rectangle only depends on the radius.
	var radius:float = circle.radius
	return Rect2(Vector2(-radius, -radius) - circle.pivot, Vector2(radius * 2, radius * 2))
	 
## If we override _edit_get_rect, we also must override _edit_set_rect. This
## function will be called by the editor if the user modifies the bounding
## rectangle, and we need to apply the new rectangle to our node.	
func _edit_set_rect(gizmo: EditorCanvasItemGizmo, boundary: Rect2) -> void:
	# Most of the time, we want to do the same thing as the built-in nodes.
	# We look at how the bounding rectangle changed and modify the transform
	# of the node. Because we need to do this often, there is a built-in helper
	# method for this.
	var old_boundary:Rect2 = _edit_get_rect(gizmo)
	
	# We get back a transform that represents the change...
	var new_transform:Transform2D = boundary_change_to_transform(old_boundary, boundary)
	
	var circle:Circle = gizmo.get_canvas_item()
	# ..and we can multiply this with the existing transform to get
	# the new position and scale of the node.
	circle.transform *= new_transform
	
	# The editor handles undo and redo for these size changes so
	# that is not something we need to care about.

## This tells the editor whether our canvas item has a custom pivot.
## Enabling this, will draw the custom pivot and allow the user to change it.	
func _has_pivot(_gizmo: EditorCanvasItemGizmo) -> bool:
	return true
	
## Returns the position of the pivot relative to the node's position. Note that
## this must return the position where pivot should be drawn.
func _get_pivot(_gizmo: EditorCanvasItemGizmo) -> Vector2:
	# Since our circle implements the pivot by offsetting the drawing, the
	# pivot point is always at the node position, so we return Vector2.ZERO here.	
	return Vector2.ZERO
	
## Updates the position of the pivot. The given given pivot is relative to the 
## node's position.	
func _set_pivot(gizmo: EditorCanvasItemGizmo, pivot: Vector2) -> void:
	var circle:Circle = gizmo.get_canvas_item()
	# The new pivot we get here is relative to the node position. Since
	# we offset the circle drawing by the pivot, our pivot position is always
	# at the node position. This means that the pivot we get is relative to
	# our old pivot (which visually was at the node position). Therefore we add 
	# it to the circle's pivot rather than overwriting it. If you implement 
	# pivots differently, you may need to do different calculations here.
	circle.pivot = circle.pivot + pivot
	
## When dragging the pivot around, the editor constantly takes snapshots of the editor
## state and restores them before applying a new pivot. It also uses these snapshots
## to provide undo/redo for pivot movement, so we don't have to take care of this. 	
func _edit_get_state(gizmo: EditorCanvasItemGizmo) -> Dictionary:
	var circle:Circle = gizmo.get_canvas_item()
	# the base state (transform, etc.) is automatically saved from the 
	# underlying node, so we only need to add what is custom to our node. In our case
	# this is just the pivot field.
	return {"pivot" : circle.pivot }	
	
## The editor calls this when a snapshot is to be restored. Note that this implementation
## is called before the underlying canvas item's implementation, so we can be sure we see
## the exact same state that we had right after creating the snapshot.	
func _edit_set_state(gizmo: EditorCanvasItemGizmo, state: Dictionary) -> void:
	var circle:Circle = gizmo.get_canvas_item()
	# Again, the underlying CanvasItem will restore the transform, so we only need
	# to take care about the pivot.
	circle.pivot = state.pivot

## We can override _redraw to add custom selection shapes and handles that makes working
## with our nodes nicer in the editor. 
func _redraw(gizmo: EditorCanvasItemGizmo) -> void:
	# By default, the Godot editor has no idea how the shape of our
	# custom node is. So it treats it as a single point, which makes selecting it
	# in the 2D view rather difficult. We can add collision shapes, so the editor 
	# can actually pick something.
	
	# A simple way would be to just use the boundary as a collision
	# shape (remove the comment from the following line to test it).
	# gizmo.add_collision_rect(_edit_get_rect(gizmo))
	
	# But that has the problem that if we click in the corners 
	# of that rect, where no circle exists, it will still get selected.
	# So we rather create a collision shape that is closer to a circle.
	# We use a 16 segment approximation here as it is good enough for
	# our purposes.
	var circle:Circle = gizmo.get_canvas_item()

	var circle_polygon:PackedVector2Array = []
	for i:int in 16:
		var angle:float = i * TAU / 16.0
		circle_polygon.append(
			(Vector2(cos(angle), sin(angle)) * circle.radius)
			- circle.pivot # drawing is offset by the pivot, so we need to take this into account
		)
	gizmo.add_collision_polygon(circle_polygon)			

	# Lets also add a custom handle so we can edit the radius nicely
	# in the editor rather than having to do it in the inspector.
	# For this we use the add_handles function on the gizmo. We need 
	# to give it the position of all the handles we want to have for
	# our node. We just need one for now.
	
	# Handle positions are relative to the node. We put the radius handle
	# at a 45 degree angle, so it doesn't overlap with the scaling handles
	var handle_pos:Vector2 = \
		Vector2(sin(PI/4.0), cos(PI/4.0)) * circle.radius \
		- circle.pivot
	gizmo.add_handles([handle_pos])	
	
## If we add custom handles, we should override this method to give the editor
## the name of the handle. This is used to show the user what will change if 
## they drag the handle.	
func _get_handle_name(_gizmo: EditorCanvasItemGizmo, handle_id: int, _secondary: bool) -> String:
	# The handle id by default is its position in the handles array that we gave it 
	# in the add_handles call (see above).
	if handle_id == 0:
		return "Radius"	
	
	# Should not happen since we only have one handle, but defensive coding
	# doesn't hurt. 
	return "Unknown handle"

## Overriding this method will allow the editor to get the value that is associated with
## the handle. The editor calls this when the user drags on a handle to show the current
## value to the user. The value is also used later to commit or abort a handle drag.
func _get_handle_value(gizmo: EditorCanvasItemGizmo, handle_id: int, _secondary: bool) -> Variant:
	# Our only handle represents the radius, so we give the radius of our
	# associated circle node back.
	var circle:Circle = gizmo.get_canvas_item()
	
	if handle_id == 0:
		return circle.radius	
	
	# Again, should not happen.
	return "?"

## While the user is dragging the handle, the editor will repeatedly call this function
## with the updated position. It is then up to us to decide what the position change actually
## means and apply it to the node.
func _set_handle(gizmo: EditorCanvasItemGizmo, handle_id: int, _secondary: bool, position: Vector2) -> void:
	# shouldn't happen, we only have one handle
	if handle_id != 0:
		return
		
	var circle:Circle = gizmo.get_canvas_item()
	
	# The position that we get is relative to the node, so we can just
	# look at how far away from the center the user has dragged the handle
	# to set the new radius
	
	# The center is offset by the pivot
	var center := -circle.pivot
	var new_radius:float = (position - center).length()
	circle.radius = new_radius
	
## Once the user releases the handle or aborts the handle movement, the editor will call this method
## so we can apply the change to the node or revert back to the original value. Unlike the position and
## size change, the editor cannot do undo/redo for us because it doesn't know what the handles actually
## change. So we need to handle this ourselves.	
func _commit_handle(gizmo: EditorCanvasItemGizmo, handle_id: int, _secondary: bool, restore: Variant, cancel: bool) -> void:	
	if handle_id != 0:
		return
		
	var circle:Circle = gizmo.get_canvas_item()
	
	# The cancel parameter tells us whether we need to revert the change or 
	# commit it. When reverting, we can simply apply the original value which is
	# given to us in the restore parameter:
	if cancel:
		circle.radius = restore
		# Since nothing has effectively changed, we don't need to add any undo/redo code.
		return
	
	# Otherwise, we need to create an undo/redo action for the change:
	var undo_redo:EditorUndoRedoManager = EditorInterface.get_editor_undo_redo()
	undo_redo.create_action("Set radius ")
	undo_redo.add_do_property(circle, "radius", circle.radius)
	undo_redo.add_undo_property(circle, "radius", restore)
	undo_redo.commit_action()
			
