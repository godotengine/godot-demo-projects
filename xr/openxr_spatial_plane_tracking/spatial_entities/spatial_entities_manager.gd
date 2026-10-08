class_name SpatialEntitiesManager
extends Node3D

## Spatial entity manager handles adding subscenes as new spatial entities are discovered.
## This script is based on: https://docs.godotengine.org/en/stable/tutorials/xr/openxr_spatial_entities.html#creating-our-spatial-manager

#region Signals
## Signals a new spatial entity node was added.
signal added_spatial_entity(node: XRNode3D)

## Signals a spatial entity node is about to be removed.
signal removed_spatial_entity(node: XRNode3D)
#endregion

#region Export variables
## Scene to instantiate for spatial anchor entities.
@export var spatial_anchor_scene: PackedScene

## Scene to instantiate for plane tracking spatial entities.
@export var plane_tracker_scene: PackedScene

## Scene to instantiate for marker tracking spatial entities.
@export var marker_tracker_scene: PackedScene
#endregion

#region Private variables
# Our current active spatial entities manager (last one instantiated)
static var _current_manager: SpatialEntitiesManager

# Trackers we manage nodes for.
var _managed_nodes: Dictionary[XRTracker, XRAnchor3D]
#endregion

#region Public methods
## Retrieve the scene we've added for a given tracker (if any).
func get_tracked_scene(p_tracker: XRTracker) -> XRNode3D:
	for node in get_children():
		if node is XRNode3D and node.tracker == p_tracker.name:
			return node

	return null
#endregion


#region Build in private functions
# Enter tree is called whenever our node is added into our scene.
func _enter_tree():
	# This is now our current manager.
	_current_manager = self

	# Connect to signals that inform us about tracker changes.
	XRServer.tracker_added.connect(_on_tracker_added)
	XRServer.tracker_updated.connect(_on_tracker_updated)
	XRServer.tracker_removed.connect(_on_tracker_removed)

	# Set up existing trackers.
	var trackers: Dictionary = XRServer.get_trackers(XRServer.TRACKER_ANCHOR)
	for tracker_name in trackers:
		var tracker: XRTracker = trackers[tracker_name]
		if tracker:
			_add_tracker(tracker)


# Exit tree is called whenever our node is removed from out scene.
func _exit_tree():
	# If we are the current manager, bye!
	if _current_manager == self:
		_current_manager = null

	# Clean up our signals.
	XRServer.tracker_added.disconnect(_on_tracker_added)
	XRServer.tracker_updated.disconnect(_on_tracker_updated)
	XRServer.tracker_removed.disconnect(_on_tracker_removed)

	# Clean up.
	for tracker in _managed_nodes:
		removed_spatial_entity.emit(_managed_nodes[tracker])
		remove_child(_managed_nodes[tracker])
		_managed_nodes[tracker].queue_free()
	_managed_nodes.clear()
#endregion


#region Private methods
# See if this tracker should be managed by us and add it
func _add_tracker(tracker: XRTracker):
	var new_node: XRAnchor3D

	if _managed_nodes.has(tracker):
		# Already being managed by us!
		return

	if tracker is OpenXRAnchorTracker:
		# Note: Generally spatial anchors are controlled by the developer and
		# are unlikely to be handled by our manager.
		# But just for completion we'll add it in.
		if spatial_anchor_scene:
			var new_scene = spatial_anchor_scene.instantiate()
			if new_scene is XRAnchor3D:
				new_node = new_scene
			else:
				push_error("Spatial anchor scene doesn't have an XRAnchor3D as a root node and can't be used!")
				new_scene.free()
	elif tracker is OpenXRPlaneTracker:
		if plane_tracker_scene:
			var new_scene = plane_tracker_scene.instantiate()
			if new_scene is XRAnchor3D:
				new_node = new_scene
			else:
				push_error("Plane tracking scene doesn't have an XRAnchor3D as a root node and can't be used!")
				new_scene.free()
	elif tracker is OpenXRMarkerTracker:
		if marker_tracker_scene:
			var new_scene = marker_tracker_scene.instantiate()
			if new_scene is XRAnchor3D:
				new_node = new_scene
			else:
				push_error("Marker tracking scene doesn't have an XRAnchor3D as a root node and can't be used!")
				new_scene.free()
	elif tracker is OpenXRSpatialEntityTracker:
		# Type of spatial entity tracker we're not supporting?
		push_warning("OpenXR Spatial Entities: Unsupported anchor tracker " + tracker.get_name() + " of type " + tracker.get_class())
	else:
		# Not a type managed by us!
		return

	if not new_node:
		# No scene defined or able to be instantiated? We're done!
		return

	# Set up and add to our scene.
	new_node.tracker = tracker.name
	new_node.pose = "default"
	_managed_nodes[tracker] = new_node
	add_child(new_node)

	added_spatial_entity.emit(new_node)
#endregion

#region Signal handling
# A new tracker was added to our XRServer.
func _on_tracker_added(tracker_name: StringName, type: int):
	print("Added tracker ", tracker_name)
	if type == XRServer.TRACKER_ANCHOR:
		var tracker: XRTracker = XRServer.get_tracker(tracker_name)
		if tracker:
			_add_tracker(tracker)


# A tracked managed by XRServer was changed.
func _on_tracker_updated(_tracker_name: StringName, _type: int):
	# For now we ignore this, there aren't changes here we need to react
	# to and the instanced scene can react to this itself if needed.
	pass


# A tracker was removed from our XRServer.
func _on_tracker_removed(tracker_name: StringName, type: int):
	if type == XRServer.TRACKER_ANCHOR:
		var tracker: XRTracker = XRServer.get_tracker(tracker_name)
		if _managed_nodes.has(tracker):
			# We emit this right before we remove it!
			removed_spatial_entity.emit(_managed_nodes[tracker])

			# Remove the node.
			remove_child(_managed_nodes[tracker])

			# Queue free the node.
			_managed_nodes[tracker].queue_free()

			# And remove from our managed nodes.
			_managed_nodes.erase(tracker)
#endregion
