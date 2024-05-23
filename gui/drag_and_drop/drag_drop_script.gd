extends ColorPickerButton

# Returns the data to pass from an object when you click and drag away from
# this object. Also calls `set_drag_preview()` to show the mouse dragging
# something so the user knows that the operation is working.
func _get_drag_data(_at_position: Vector2) -> Color:
	# Use another colorpicker as drag preview.
	var cpb := ColorPickerButton.new()
	cpb.color = color
	cpb.size = Vector2(80.0, 50.0)

	# Allows us to center the color picker on the mouse.
	var preview := Control.new()
	preview.add_child(cpb)
	cpb.position = -0.5 * cpb.size

	# Sets what the user will see they are dragging.
	set_drag_preview(preview)

	# Return color as drag data.
	return color


# Returns a boolean by examining the data being dragged to see if it's valid
# to drop here.
func _can_drop_data(_at_position: Vector2, data: Variant) -> bool:
	return typeof(data) == TYPE_COLOR


# Takes the data being dragged and processes it. In this case, we are
# assigning a new color to the target color picker button.
func _drop_data(_at_position: Vector2, data: Variant) -> void:
	color = data
