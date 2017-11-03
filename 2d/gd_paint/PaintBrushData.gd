extends Reference

# The type of brush this brush object is. There are only four types:
# 'pencil', 'eraser', 'rectangle shape' and 'circle shape'
var brush_type = "pencil"

# The position of the brush, generally the center of the brush (see Paint_control.gd)
var brush_pos = Vector2()

# the shape of the brush (only applies to the pencil and eraser)
# It can be either 'box' or 'circle'
var brush_shape = "box"

# the size (in pixels) of the brush
var brush_size = 32

# the color of the brush
var brush_color = Color(1, 1, 1, 1)

# The bottom right corner of the rectangle shape (if the brush type is 'rectangle shape')
# NOTE: The top left corner is assumed to be assigned to brush_pos
var brush_shape_rect_pos_BR = Vector2()

# The radius of the circle shape (if the brush type is 'circle shape')
# NOTE: It's assumed that brush_pos is the center of the the circle
var brush_shape_circle_radius = 0
