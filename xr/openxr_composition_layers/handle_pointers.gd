extends OpenXRCompositionLayerEquirect

const NO_INTERSECTION = Vector2(-1.0, -1.0)

@export var controller : XRController3D
@export var button_action : String = "select"

var was_pressed : bool = false
var was_intersect : Vector2 = NO_INTERSECTION


# Pass input events on to viewport.
func _input(event):
	if not layer_viewport:
		return

	if event is InputEventMouse:
		# Desktop mouse events do not translate so ignore.
		return

	# Anything else, just pass on!
	layer_viewport.push_input(event)


# Convert the intersect point reurned by intersects_ray to local coords in the viewport.
func _intersect_to_viewport_pos(intersect : Vector2) -> Vector2i:
	if layer_viewport and intersect != NO_INTERSECTION:
		var pos : Vector2 = intersect * Vector2(layer_viewport.size)
		return Vector2i(pos)
	else:
		return Vector2i(-1, -1)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	if not controller:
		return
	if not layer_viewport:
		return

	var controller_t : Transform3D = controller.global_transform
	var intersect : Vector2 = intersects_ray(controller_t.origin, -controller_t.basis.z)

	if intersect != NO_INTERSECTION:
		var is_pressed : bool = controller.is_button_pressed(button_action)

		if was_intersect != NO_INTERSECTION and intersect != was_intersect:
			# Pointer moved
			var event : InputEventMouseMotion = InputEventMouseMotion.new()
			var from : Vector2 = _intersect_to_viewport_pos(was_intersect)
			var to : Vector2 = _intersect_to_viewport_pos(intersect)
			if was_pressed:
				event.button_mask = MOUSE_BUTTON_MASK_LEFT
			event.relative = to - from
			event.position = to
			layer_viewport.push_input(event)

		if not is_pressed and was_pressed:
			# Button was let go?
			var event : InputEventMouseButton = InputEventMouseButton.new()
			event.button_index = MOUSE_BUTTON_LEFT
			event.pressed = false
			event.position = _intersect_to_viewport_pos(intersect)
			layer_viewport.push_input(event)

		elif is_pressed and not was_pressed:
			# Button was pressed?
			var event : InputEventMouseButton = InputEventMouseButton.new()
			event.button_index = MOUSE_BUTTON_LEFT
			event.button_mask = MOUSE_BUTTON_MASK_LEFT
			event.pressed = true
			event.position = _intersect_to_viewport_pos(intersect)
			layer_viewport.push_input(event)

		was_pressed = is_pressed
		was_intersect = intersect

	else:
		was_pressed = false
		was_intersect = NO_INTERSECTION
