extends RigidBody3D
class_name PickupAbleBody3D


var highlight_material : Material = preload("res://shaders/highlight_material.tres")
var picked_up_by : Area3D
var closest_areas : Array

var original_parent : Node3D
var tween : Tween

# Called when this object becomes the closest body in an area
func add_is_closest(area : Area3D) -> void:
	if not closest_areas.has(area):
		closest_areas.push_back(area)

	_update_highlight()


# Called when this object becomes the closest body in an area
func remove_is_closest(area : Area3D) -> void:
	if closest_areas.has(area):
		closest_areas.erase(area)

	_update_highlight()


# Returns whether we have been picked up.
func is_picked_up() -> bool:
	# If we have a valid picked up by object,
	# we've been picked up
	if picked_up_by:
		return true

	return false


# Pick this object up.
func pick_up(pick_up_by) -> void:
	# Already picked up? Can't pick up twice.
	if picked_up_by:
		if picked_up_by == pick_up_by:
			return

		let_go()

	# Remember some state we want to reapply on release.
	original_parent = get_parent()
	var current_transform = global_transform

	# Remove us from our old parent.
	original_parent.remove_child(self)

	# Process our pickup.
	picked_up_by = pick_up_by
	picked_up_by.add_child(self)
	global_transform = current_transform
	freeze = true

	# Kill any existing tween and create a new one.
	if tween:
		tween.kill()
	tween = create_tween()

	# Snap the object to this transform.
	var snap_to : Transform3D

	# Add code here to determine snap position and orientation.

	# Now tween
	tween.tween_property(self, "transform", snap_to, 0.1)


# Let this object go.
func let_go() -> void:
	# Ignore if we haven't been picked up.
	if not picked_up_by:
		return

	# Cancel any ongoing tween
	if tween:
		tween.kill()
		tween = null

	# Remember our current transform.
	var current_transform = global_transform

	# Remove us from what picked us up.
	picked_up_by.remove_child(self)
	picked_up_by = null

	# Reset some state.
	original_parent.add_child(self)
	global_transform = current_transform
	freeze = false


# Update our highlight to show that we can be picked up
func _update_highlight() -> void:
	if not picked_up_by and not closest_areas.is_empty():
		# add highlight
		for child in get_children():
			if child is MeshInstance3D:
				var mesh_instance : MeshInstance3D = child
				mesh_instance.material_overlay = highlight_material
	else:
		# remove highlight
		for child in get_children():
			if child is MeshInstance3D:
				var mesh_instance : MeshInstance3D = child
				mesh_instance.material_overlay = null
