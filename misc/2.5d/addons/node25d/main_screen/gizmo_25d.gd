tool
extends Node2D

# Not pixel perfect for all axes in all modes, but works well enough.
# Rounding is not done until after the movement is finished.
const ROUGHLY_ROUND_TO_PIXELS = true

# Set when the node is created.
var node_25d: Node25D
var spatial_node

# Input from Viewport25D, represents if the mouse is clicked.
var wants_to_move = false

# Used to control the state of movement.
var _moving = false
var _start_position = Vector2()

# Stores state of closest or currently used axis.
var dominant_axis

onready var lines_root = $Lines
onready var lines = [$Lines/X, $Lines/Y, $Lines/Z]

func _process(_delta):
	if !lines:
		return # Somehow this node hasn't been set up yet.
	if !node_25d:
		return # We're most likely viewing the Gizmo25D scene.
	# While getting the mouse position works in any viewport, it doesn't do
	# anything significant unless the mouse is in the 2.5D viewport.
	var mouse_position = get_local_mouse_position()
	if !_moving:
		# If the mouse is farther than this many pixels, it won't grab anything.
		var closest_distance = 20.0
		dominant_axis = -1
		for i in range(3):
			lines[i].modulate.a = 0.8 # Unrelated, but needs a loop too.
			var distance = _distance_to_segment_at_index(i, mouse_position)
			if distance < closest_distance:
				closest_distance = distance
				dominant_axis = i
		if dominant_axis == -1:
			# If we're not hovering over a line, ensure they are placed correctly.
			lines_root.global_position = node_25d.global_position
			return

	lines[dominant_axis].modulate.a = 1
	if !wants_to_move:
		_moving = false
	elif wants_to_move and !_moving:
		_moving = true
		_start_position = mouse_position

	if _moving:
		# Change modulate of unselected axes.
		lines[(dominant_axis + 1) % 3].modulate.a = 0.5
		lines[(dominant_axis + 2) % 3].modulate.a = 0.5
		# Calculate mouse movement and reset for next frame.
		var mouse_diff = mouse_position - _start_position
		_start_position = mouse_position
		# Calculate movement.
		var projected_diff = mouse_diff.project(lines[dominant_axis].points[1])
		var movement = projected_diff.length() / Node25D.SCALE
		if is_equal_approx(PI, projected_diff.angle_to(lines[dominant_axis].points[1])):
			movement *= -1
		# Apply movement.
		spatial_node.transform.origin += spatial_node.transform.basis[dominant_axis] * movement
	else:
		# Make sure the gizmo is located at the object.
		global_position = node_25d.global_position
		if ROUGHLY_ROUND_TO_PIXELS:
			spatial_node.transform.origin = (spatial_node.transform.origin * Node25D.SCALE).round() / Node25D.SCALE
	# Move the gizmo lines appropriately.
	lines_root.global_position = node_25d.global_position
	node_25d.property_list_changed_notify()


# Initializes after _ready due to the onready vars, called manually in Viewport25D.gd.
# Sets up the points based on the basis values of the Node25D.
func initialize():
	var basis = node_25d.get_basis()
	for i in range(3):
		lines[i].points[1] = basis[i] * 3
	global_position = node_25d.global_position
	spatial_node = node_25d.get_child(0)


# Figures out if the mouse is very close to a segment. This method is
# specialized for this script, it assumes that each segment starts at
# (0, 0) and it provides a deadzone around the origin.
func _distance_to_segment_at_index(index, point):
	if !lines:
		return INF
	if point.length_squared() < 400:
		return INF

	var segment_end = lines[index].points[1]
	var length_squared = segment_end.length_squared()
	if length_squared < 400:
		return INF

	var t = clamp(point.dot(segment_end) / length_squared, 0, 1)
	var projection = t * segment_end
	return point.distance_to(projection)
