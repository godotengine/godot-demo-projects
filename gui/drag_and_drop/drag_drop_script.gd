
extends ColorPickerButton


func get_drag_data(_pos):
	# Use another colorpicker as drag preview
	var cpb = ColorPickerButton.new()
	cpb.color = color
	cpb.rect_size = Vector2(50, 50)
	set_drag_preview(cpb)
	# Return color as drag data
	return color


func can_drop_data(_pos, data):
	return typeof(data) == TYPE_COLOR


func drop_data(_pos, data):
	color = data
