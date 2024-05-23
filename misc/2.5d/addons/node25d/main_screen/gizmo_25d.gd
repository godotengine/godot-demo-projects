@tool
extends Node2D

# If the mouse is farther than this many pixels, it won't grab anything.
const DEADZONE_RADIUS = 20.0
const DEADZONE_RADIUS_SQ = DEADZONE_RADIUS * DEADZONE_RADIUS
# Not pixel perfect for all axes in all modes, but works well enough.
# Rounding is not done until after the movement is finished.
const ROUGHLY_ROUND_TO_PIXELS = true

# Set when the node is created.
var node_25d: Node25D
var _spatial_node: Node3D

# Input from Viewport25D, represents if the mouse is clicked.
var wants_to_move = false

# Used to control the state of movement.
var _moving = false
var _start_mouse_position := Vector2.ZERO

# Stores state of closest or currently used axis.
var _dominant_axis

@onready var _lines = [$X, $Y, $Z]
@onready var _viewport_overlay: SubViewport = get_parent()
@onready var _viewport_25d_bg: ColorRect = _viewport_overlay.get_parent()


func _process(_delta):
	if not _lines:
		return  # Somehow this node hasn't been set up yet.
	if not node_25d or not _viewport_25d_bg:
		return  # We're most likely viewing the Gizmo25D scene.
	global_position = node_25d.global_position
	# While getting the mouse position works in any viewport, it doesn't do
	# anything significant unless the mouse is in the 2.5D viewport.
	var mouse_position: Vector2 = _viewport_25d_bg.get_local_mouse_position()
	var full_transform: Transform2D = _viewport_overlay.canvas_transform * global_transform
	mouse_position = full_transform.affine_inverse() * mouse_position
	if not _moving:
		determine_dominant_axis(mouse_position)
		if _dominant_axis == -1:
			# If we're not hovering over a line, nothing to do.
			return
	_lines[_dominant_axis].modulate.a = 1
	if not wants_to_move:
		if _moving:
			# When we're done moving, ensure the inspector is updated.
			node_25d.notify_property_list_changed()
			_moving = false
		return
	# By this point, we want to move.
	if not _moving:
		_moving = true
		_start_mouse_position = mouse_position
	# By this point, we are moving.
	move_using_mouse(mouse_position)


func determine_dominant_axis(mouse_position: Vector2) -> void:
	var closest_distance = DEADZONE_RADIUS
	_dominant_axis = -1
	for i in range(3):
		_lines[i].modulate.a = 0.8  # Unrelated, but needs a loop too.
		var distance = _distance_to_segment_at_index(i, mouse_position)
		if distance < closest_distance:
			closest_distance = distance
			_dominant_axis = i


func move_using_mouse(mouse_position: Vector2) -> void:
	# Change modulate of unselected axes.
	_lines[(_dominant_axis + 1) % 3].modulate.a = 0.5
	_lines[(_dominant_axis + 2) % 3].modulate.a = 0.5
	# Calculate movement.
	var mouse_diff: Vector2 = mouse_position - _start_mouse_position
	var line_end_point: Vector2 = _lines[_dominant_axis].points[1]
	var projected_diff: Vector2 = mouse_diff.project(line_end_point)
	var movement: float = projected_diff.length() * global_scale.x / Node25D.SCALE
	if is_equal_approx(PI, projected_diff.angle_to(line_end_point)):
		movement *= -1
	# Apply movement.
	var move_dir_3d: Vector3 = _spatial_node.transform.basis[_dominant_axis]
	_spatial_node.transform.origin += move_dir_3d * movement
	_snap_spatial_position()
	# Move the gizmo appropriately.
	global_position = node_25d.global_position


# Setup after _ready due to the onready vars, called manually in Viewport25D.gd.
# Sets up the points based on the basis values of the Node25D.
func setup(in_node_25d: Node25D):
	node_25d = in_node_25d
	var basis = node_25d.get_basis()
	for i in range(3):
		_lines[i].points[1] = basis[i] * 3
	global_position = node_25d.global_position
	_spatial_node = node_25d.get_child(0)


func set_zoom(zoom: float) -> void:
	var new_scale: float = EditorInterface.get_editor_scale() / zoom
	global_scale = Vector2(new_scale, new_scale)


func _snap_spatial_position(step_meters: float = 1.0 / Node25D.SCALE) -> void:
	var scaled_px: Vector3 = _spatial_node.transform.origin / step_meters
	_spatial_node.transform.origin = scaled_px.round() * step_meters


# Figures out if the mouse is very close to a segment. This method is
# specialized for this script, it assumes that each segment starts at
# (0, 0) and it provides a deadzone around the origin.
func _distance_to_segment_at_index(index, point):
	if not _lines:
		return INF
	if point.length_squared() < DEADZONE_RADIUS_SQ:
		return INF

	var segment_end: Vector2 = _lines[index].points[1]
	var length_squared = segment_end.length_squared()
	if length_squared < DEADZONE_RADIUS_SQ:
		return INF

	var t = clamp(point.dot(segment_end) / length_squared, 0, 1)
	var projection = t * segment_end
	return point.distance_to(projection)
