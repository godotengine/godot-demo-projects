extends Control

# Some margin to keep the marker away from the screen's corners.
const MARGIN = 5

onready var camera = get_viewport().get_camera()
onready var label = $Label
onready var marker = $Marker

# The waypoint's text.
export var text = "" setget set_text

# If `true`, the waypoint sticks to the viewport's edges when moving off-screen.
export var sticky = true


func _ready() -> void:
	self.text = text

	if not get_parent() is Spatial:
		push_error("The waypoint's parent node must inherit from Spatial.")


func _process(_delta):
	var parent_translation = get_parent().global_transform.origin
	var camera_translation = camera.global_transform.origin

	# The waypoint should be visible only if it's in front of the camera.
	# FIXME: The off-screen arrow doesn't always display at the correct location.
	visible = !camera.is_position_behind(parent_translation)

	if visible:
		# Fade the waypoint when the camera gets close
		modulate.a = clamp(
				range_lerp(camera_translation.distance_to(parent_translation), 0, 2, 0, 1),
				0,
				1
		)

		var unprojected_position = camera.unproject_position(parent_translation)
		# `get_size_override()` will return a valid size only if the stretch mode is `2d`.
		# Otherwise, the viewport size is used directly.
		var viewport_base_size = (
				get_viewport().get_size_override() if get_viewport().get_size_override() > Vector2(0, 0)
				else get_viewport().size
		)

		if sticky:
			rect_position = Vector2(
					clamp(unprojected_position.x, MARGIN, viewport_base_size.x - MARGIN),
					clamp(unprojected_position.y, MARGIN, viewport_base_size.y - MARGIN)
			)
			label.visible = true
			marker.rect_rotation = 0
			# Used to display a diagonal arrow when the waypoint is displayed in
			# one of the screen corners.
			var overflow_left = false
			var overflow_right = false

			if rect_position.x <= MARGIN:
				# Left overflow.
				overflow_left = true
				label.visible = false
				marker.rect_rotation = 90
			elif rect_position.x >= viewport_base_size.x - MARGIN:
				# Right overflow.
				overflow_right = true
				label.visible = false
				marker.rect_rotation = 270

			if rect_position.y <= MARGIN:
				# Top overflow.
				label.visible = false
				marker.rect_rotation = (
						135 if overflow_left
						else 225 if overflow_right
						else 180
				)
			elif rect_position.y >= viewport_base_size.y - MARGIN:
				# Bottom overflow.
				label.visible = false
				marker.rect_rotation = (
						45 if overflow_left
						else 315 if overflow_right
						else 0
				)
		else:
			rect_position = unprojected_position


func set_text(p_text):
	text = p_text

	# The label's text can only be set once the node is ready.
	if is_inside_tree():
		label.text = p_text
