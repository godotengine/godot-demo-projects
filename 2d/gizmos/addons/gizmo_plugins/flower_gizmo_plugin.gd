# This is the gizmo plugin that provides editor support for our Flower node.
# It uses the same principles and functions that the Circle gizmo plugin uses
# so have a look at the Circle gizmo plugin first to get an overview on how
# these functions work. 
#
# This plugin adds subgizmos. Subgizmos are similar to handles, but unlike handles, 
# they can be selected and transformed - handles can only be moved but not selected. 
# Usually you will use subgizmos for sub-structure parts of the node. In this example we 
# use them for the flower petals. Other good use cases for subgizmos would be the 
# vertices of a path or a polygon, while e.g. the tangent handles of a bezier curve would
# rather be done with handles.
@tool
extends EditorCanvasItemGizmoPlugin

func _has_gizmo(for_canvas_item: CanvasItem) -> bool:
	return for_canvas_item is Flower

func _get_gizmo_name() -> String:
	return "Flower"

## The flower isn't supposed to be user scalable. We can only move the node and each 
## individual petal. So this method returns false, and the editor will not show transform 
## gizmos for this node.
func _edit_use_rect(_gizmo: EditorCanvasItemGizmo) -> bool:
	return false
	
	
func _redraw(gizmo: EditorCanvasItemGizmo) -> void:
	var flower:Flower = gizmo.get_canvas_item()
	
	# We add selection shapes for the flower disk and petals so the user can
	# easily pick any part of the flower.
	gizmo.add_collision_polygon(_calculate_collision_circle(flower.radius, Transform2D()))			
	
	for i:int in flower._petals.size():
		var petal:Transform2D = flower._petals[i]
		var polygon:PackedVector2Array = _calculate_collision_circle(flower.radius, petal) 
		gizmo.add_collision_polygon(polygon)
	
		# We also draw an overlay to show the currently selected
		# petals. Petals are subgizmos. See the subgizmo selection
		# functions below.
		if gizmo.is_subgizmo_selected(i):
			gizmo.add_polygon(polygon, Color(0.39215687, 0.58431375, 0.92941177, 0.8))
					
	
	# Like for the circle node, lets add a handle to conveniently set the 
	# radius of the flower disk.
	var handle_pos:Vector2 = Vector2(sin(PI/4.0), cos(PI/4.0)) * flower.radius
	gizmo.add_handles([handle_pos])	
	
	
## Since we need the collision circles also for our subgizmos (see below), we have a helper method
## for calculating these.	
func _calculate_collision_circle(radius:float, transform:Transform2D) -> PackedVector2Array:
	# Collision polygon is calculated very similar to how it's done for the circle
	var circle_polygon:PackedVector2Array = []
	for i:int in 16:
		var angle:float = i * TAU / 16.0
		var point:Vector2 = Vector2(cos(angle), sin(angle)) * radius
		# except we multiply it with the transform to get the position and shape of the petals.
		circle_polygon.append(transform * point)
	
	return circle_polygon
			
## This function is called when the user clicks in the editor. We can override it to 
## return the ID of a subgizmo that exists at the given location. For our flower, the
## petals are subgizmos. So when given point is over a petal, we return the index of 
## that petal.
func _subgizmos_intersect_point(gizmo: EditorCanvasItemGizmo, point: Vector2, _distance: float) -> int:
	var flower:Flower = gizmo.get_canvas_item()
	
	# We walk over the petals, create a collision polygon for each and check if the
	# given point is inside. If this is the case we return the index of the petal as our
	# subgizmo ID. The point we get is already in local coordinates, so we don't need
	# to do any extra calculations
	for i:int in flower._petals.size():
		var petal:Transform2D = flower._petals[i]
		var collision_polygon:PackedVector2Array = _calculate_collision_circle(flower.radius, petal)
		if Geometry2D.is_point_in_polygon(point, collision_polygon):
			return i
	
	return -1
	
## This function is called when the user does a subgizmo rectangle selection (e.g. shift + drag).
## We can override this to return the IDs of all subgizmos that are inside of the rect.	
func _subgizmos_intersect_rect(gizmo: EditorCanvasItemGizmo, rect: Rect2) -> PackedInt32Array:
	var flower:Flower = gizmo.get_canvas_item()
	var result:PackedInt32Array = []
	
	# We can in principle use the same approach here as we did in _subgizmos_intersect_point.
	# However the rectangle is given in canvas coordinates and not in local coordinates, because
	# it represents a rectangular selection on the canvas. So we need to find all petals that
	# have an overlap with this rectangle. To do this, we need the flower's global transform 
	# to calculate collision shapes in canvas space.
	var global_transform:Transform2D = flower.global_transform

	# We also need a polygon representation of the selection rect to calculate the overlap later.
	var rect_shape:PackedVector2Array = []
	
	# Godot expects polygons to be clockwise, so that's what we do here.
	rect_shape.append(rect.position)
	rect_shape.append(rect.position + Vector2(0, rect.size.y))
	rect_shape.append(rect.position + rect.size)
	rect_shape.append(rect.position + Vector2(rect.size.x, 0))
	
	for i in flower._petals.size():
		# apply the global transform of the flower, so we get a collision shape in global
		# coordinates.
		var petal_global:Transform2D = global_transform * flower._petals[i]
		var collision_polygon:PackedVector2Array = _calculate_collision_circle(flower.radius, petal_global)
	
		# Now we can perform an intersect operation between the rect shape and the collision polygon.
		# If this is not empty, we have an overlap.
		var overlap:Array[PackedVector2Array] = Geometry2D.intersect_polygons(rect_shape, collision_polygon)
		if not overlap.is_empty():
			result.append(i)
			
	return result		
	
## This is called by the editor to get the transform behind a subgizmo. So this method is
## similar to _get_handle_value, that gets called for handles. Unlike handles, which can 
## represent any value, subgizmos always represent transforms. In our case we return the 
## transforms of our flower petals
func _get_subgizmo_transform(gizmo: EditorCanvasItemGizmo, subgizmo_id: int) -> Transform2D:
	var flower:Flower = gizmo.get_canvas_item()
	return flower._petals[subgizmo_id]
	
## This is called by the editor got apply a new transform to a subgizmo after the user has
## edited it in the editor. This is similar to _set_handle that gets called for handles.
func _set_subgizmo_transform(gizmo: EditorCanvasItemGizmo, subgizmo_id: int, transform: Transform2D) -> void:
	var flower:Flower = gizmo.get_canvas_item()
	flower._petals[subgizmo_id] = transform
	flower._repaint()

## This is called by the editor when the user finishes or aborts subgizmo editing. It works very
## similar to _commit_handle. So we get the IDs of the modified subgizmos and a matching array with
## how their transforms were when the modification began. The cancel parameter tells us, if the user
## cancelled the action. Like with handles, we need to do the undo/redo part ourselves here as the 
## editor cannot know how the transformed subgizmos are represented internally and what needs to be
## done to undo/redo this change.	
func _commit_subgizmos(gizmo: EditorCanvasItemGizmo, ids: PackedInt32Array, restores: Array[Transform2D], cancel: bool) -> void:
	var flower:Flower = gizmo.get_canvas_item()
	if cancel:
		# if the operation was cancelled, we simply undo the change and set back our
		# initial transforms.
		for i:int in ids.size():
			var subgizmo_id:int = ids[i]
			var old_transform:Transform2D = restores[i]
			flower._petals[subgizmo_id] = old_transform
		
		flower._repaint()
		# Since nothing really changed, we don't need to do any undo/redo here.
		return
	
	# For the undo part we need to build the undo array ourselves. So we
	# take the current state, apply the restores and use that as undo state
	var undo_petals:Array[Transform2D] = flower._petals.duplicate()
	for i:int in ids.size():
		var subgizmo_id:int = ids[i]
		var old_transform:Transform2D = restores[i]
		undo_petals[subgizmo_id] = old_transform
		
		
	var undo_redo:EditorUndoRedoManager = EditorInterface.get_editor_undo_redo()
	undo_redo.create_action("Set petals")
	undo_redo.add_do_property(flower, "_petals", flower._petals)
	undo_redo.add_do_method(flower, "_repaint" )
	undo_redo.add_undo_property(flower, "_petals", undo_petals)
	undo_redo.add_undo_method(flower, "_repaint" )
	undo_redo.commit_action()
			
		
	
# The handle management for the radius is very similar to the Circle node. Have a look there
# for details on how handles work. We're leaving the details out here for brevity.
	
func _get_handle_name(_gizmo: EditorCanvasItemGizmo, handle_id: int, _secondary: bool) -> String:
	if handle_id == 0:
		return "Radius"	
	
	return "Unknown handle"

func _get_handle_value(gizmo: EditorCanvasItemGizmo, handle_id: int, _secondary: bool) -> Variant:
	var flower:Flower = gizmo.get_canvas_item()
	
	if handle_id == 0:
		return flower.radius	
	
	# Again, should not happen.
	return "?"

func _set_handle(gizmo: EditorCanvasItemGizmo, handle_id: int, _secondary: bool, position: Vector2) -> void:
	if handle_id != 0:
		return
		
	var flower:Flower = gizmo.get_canvas_item()
	
	var new_radius:float = position.length()
	flower.radius = new_radius
	
func _commit_handle(gizmo: EditorCanvasItemGizmo, handle_id: int, _secondary: bool, restore: Variant, cancel: bool) -> void:	
	if handle_id != 0:
		return
		
	var flower:Flower = gizmo.get_canvas_item()
	
	if cancel:
		flower.radius = restore
		return
	
	var undo_redo:EditorUndoRedoManager = EditorInterface.get_editor_undo_redo()
	undo_redo.create_action("Set radius ")
	undo_redo.add_do_property(flower, "radius", flower.radius)
	undo_redo.add_undo_property(flower, "radius", restore)
	undo_redo.commit_action()
			
