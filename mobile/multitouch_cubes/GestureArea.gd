extends Control

@export var target: NodePath
@export var min_scale := 0.1
@export var max_scale := 3.0
@export var one_finger_rot_x := true
@export var one_finger_rot_y := true
@export var two_fingers_rot_z := true
@export var two_fingers_zoom := true

var base_state := {}
var curr_state := {}

# We keep here a copy of the state before the number of fingers changed to avoid accumulation errors.
var base_xform: Transform3D

@onready var target_node: Node = get_node(target)

func _gui_input(event: InputEvent) -> void:
	# We must start touching inside, but we can drag or unpress outside.
#	if not (event is InputEventScreenDrag or
#		(event is InputEventScreenTouch and (not event.pressed or get_global_rect().has_point(event.position)))):
#		return

	var finger_count := base_state.size()

	if finger_count == 0:
		# No fingers => Accept press.
		if event is InputEventScreenTouch:
			if event.pressed:
				# A finger started touching.

				base_state = {
					event.index: event.position,
				}

	elif finger_count == 1:
		# One finger => For rotating around X and Y.
		# Accept one more press, unpress or drag.
		if event is InputEventScreenTouch:
			if event.pressed:
				# One more finger started touching.

				# Reset the base state to the only current and the new fingers.
				base_state = {
					curr_state.keys()[0]: curr_state.values()[0],
					event.index: event.position,
				}
			else:
				if base_state.has(event.index):
					# Only touching finger released.

					base_state.clear()

		elif event is InputEventScreenDrag:
			if curr_state.has(event.index):
				# Touching finger dragged.
				var unit_drag := _px2unit(base_state[base_state.keys()[0]] - event.position)
				if one_finger_rot_x:
					target_node.global_rotate(Vector3.UP, deg_to_rad(180.0 * unit_drag.x))
				if one_finger_rot_y:
					target_node.global_rotate(Vector3.RIGHT, deg_to_rad(180.0 * unit_drag.y))
				# Since rotating around two axes, we have to reset the base constantly.
				curr_state[event.index] = event.position
				base_state[event.index] = event.position
				base_xform = target_node.get_transform()

	elif finger_count == 2:
		# Two fingers => To pinch-zoom and rotate around Z.
		# Accept unpress or drag.
		if event is InputEventScreenTouch:
			if not event.pressed and base_state.has(event.index):
				# Some known touching finger released.

				# Clear the base state
				base_state.clear()

		elif event is InputEventScreenDrag:
			if curr_state.has(event.index):
				# Some known touching finger dragged.
				curr_state[event.index] = event.position

				# Compute base and current inter-finger vectors.
				var base_segment: Vector3 = base_state[base_state.keys()[0]] - base_state[base_state.keys()[1]]
				var new_segment: Vector3 = curr_state[curr_state.keys()[0]] - curr_state[curr_state.keys()[1]]

				# Get the base scale from the base matrix.
				var base_scale := Vector3(base_xform.basis.x.x, base_xform.basis.y.y, base_xform.basis.z.z).length()

				if two_fingers_zoom:
					# Compute the new scale limiting it and taking into account the base scale.
					var new_scale := clampf(base_scale * (new_segment.length() / base_segment.length()), min_scale, max_scale) / base_scale
					target_node.set_transform(base_xform.scaled(new_scale * Vector3.ONE))
				else:
					target_node.set_transform(base_xform)

				if two_fingers_rot_z:
					# Apply rotation between base inter-finger vector and the current one.
					var rot := new_segment.angle_to(base_segment)
					target_node.global_rotate(Vector3.BACK, rot)

	# Finger count changed?
	if base_state.size() != finger_count:
		# Copy new base state to the current state.
		curr_state = {}
		for idx: int in base_state.keys():
			curr_state[idx] = base_state[idx]
		# Remember the base transform.
		base_xform = target_node.get_transform()


# Converts a vector in pixels to a unitary magnitude,
# considering the number of pixels of the shorter axis is the unit.
func _px2unit(v: Vector2) -> Vector2:
	var shortest := minf(get_size().x, get_size().y)
	return v * (1.0 / shortest)
