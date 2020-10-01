extends Control

# A constant for whether or not we're needing to undo a shape.
const UNDO_MODE_SHAPE = -2
# A constant for whether or not we can undo.
const UNDO_NONE = -1
# How large is the image (it's actually the size of DrawingAreaBG, because that's our background canvas).
const IMAGE_SIZE = Vector2(930, 720)

# Enums for the various modes and brush shapes that can be applied.
enum BrushModes {
	PENCIL, ERASER, CIRCLE_SHAPE, RECTANGLE_SHAPE
}
enum BrushShapes {
	RECTANGLE, CIRCLE
}

# The top-left position of the canvas.
var TL_node

# A list to hold all of the dictionaries that make up each brush.
var brush_data_list = []

# A boolean to hold whether or not the mouse is inside the drawing area, the mouse position last _process call
# and the position of the mouse when the left mouse button was pressed.
var is_mouse_in_drawing_area = false
var last_mouse_pos = Vector2()
var mouse_click_start_pos = null

# A boolean to tell whether we've set undo_elements_list_num, which holds the size of draw_elements_list
# before a new stroke is added (unless the current brush mode is 'rectangle shape' or 'circle shape', in
# which case we do things a litte differently. See the undo_stroke function for more details).
var undo_set = false
var undo_element_list_num = -1

# The current brush settings: The mode, size, color, and shape we have currently selected.
var brush_mode = BrushModes.PENCIL
var brush_size = 32
var brush_color = Color.black
var brush_shape = BrushShapes.CIRCLE;

# The color of the background. We need this for the eraser (see the how we handle the eraser
# in the _draw function for more details).
var bg_color = Color.white

func _ready():
	# Get the top left position node. We need this to find out whether or not the mouse is inside the canvas.
	TL_node = get_node("TLPos")
	set_process(true)


func _process(_delta):
	var mouse_pos = get_viewport().get_mouse_position()

	# Check if the mouse is currently inside the canvas/drawing-area.
	is_mouse_in_drawing_area = false
	if mouse_pos.x > TL_node.global_position.x:
		if mouse_pos.y > TL_node.global_position.y:
			is_mouse_in_drawing_area = true

	if Input.is_mouse_button_pressed(BUTTON_LEFT):
		# If we do not have a position for when the mouse was first clicked, then this must
		# be the first time is_mouse_button_pressed has been called since the mouse button was
		# released, so we need to store the position.
		if mouse_click_start_pos == null:
			mouse_click_start_pos = mouse_pos

		# If the mouse is inside the canvas and the mouse is 1px away from the position of the mouse last _process call.
		if check_if_mouse_is_inside_canvas():
			if mouse_pos.distance_to(last_mouse_pos) >= 1:
				# If we are in pencil or eraser mode, then we need to draw.
				if brush_mode == BrushModes.PENCIL or brush_mode == BrushModes.ERASER:
					# If undo has not been set, meaning we've started a new stroke, then store the size of the
					# draw_elements_list so we can undo from this point in time.
					if undo_set == false:
						undo_set = true
						undo_element_list_num = brush_data_list.size()
					# Add the brush object to draw_elements_array.
					add_brush(mouse_pos, brush_mode)

	else:
		# We've finished our stroke, so we can set a new undo (if a new storke is made).
		undo_set = false

		# If the mouse is inside the canvas.
		if check_if_mouse_is_inside_canvas():
			# If we're using either the circle shape mode, or the rectangle shape mode, then
			# add the brush object to draw_elements_array.
			if brush_mode == BrushModes.CIRCLE_SHAPE or brush_mode == BrushModes.RECTANGLE_SHAPE:
				add_brush(mouse_pos, brush_mode)
				# We handle undo's differently than either pencil or eraser mode, so we need to set undo
				# element_list_num to -2 so we can tell if we need to undo a shape. See undo_stroke for details.
				undo_element_list_num = UNDO_MODE_SHAPE
		# Since we've released the left mouse, we need to get a new mouse_click_start_pos next time
		#is_mouse_button_pressed is true.
		mouse_click_start_pos = null

	# Store mouse_pos as last_mouse_pos now that we're done with _process.
	last_mouse_pos = mouse_pos


func check_if_mouse_is_inside_canvas():
	# Make sure we have a mouse click starting position.
	if mouse_click_start_pos != null:
		# Make sure the mouse click starting position is inside the canvas.
		# This is so if we start out click outside the canvas (say chosing a color from the color picker)
		# and then move our mouse back into the canvas, it won't start painting.
		if mouse_click_start_pos.x > TL_node.global_position.x:
			if mouse_click_start_pos.y > TL_node.global_position.y:
				# Make sure the current mouse position is inside the canvas.
				if is_mouse_in_drawing_area:
					return true
	return false


func undo_stroke():
	# Only undo a stroke if we have one.
	if undo_element_list_num == UNDO_NONE:
		return

	# If we are undoing a shape, then we can just remove the latest brush.
	if undo_element_list_num == UNDO_MODE_SHAPE:
		if brush_data_list.size() > 0:
			brush_data_list.remove(brush_data_list.size() - 1)

		# Now that we've undone a shape, we cannot undo again until another stoke is added.
		undo_element_list_num = UNDO_NONE
		# NOTE: if we only had shape brushes, then we could remove the above line and could let the user
		# undo until we have a empty element list.

	# Otherwise we're removing a either a pencil stroke or a eraser stroke.
	else:
		# Figure out how many elements/brushes we've added in the last stroke.
		var elements_to_remove = brush_data_list.size() - undo_element_list_num
		# Remove all of the elements we've added this in the last stroke.
		#warning-ignore:unused_variable
		for elment_num in range(0, elements_to_remove):
			brush_data_list.pop_back()

		# Now that we've undone a stoke, we cannot undo again until another stoke is added.
		undo_element_list_num = UNDO_NONE

	# Redraw the brushes
	update()


func add_brush(mouse_pos, type):
	# Make new brush dictionary that will hold all of the data we need for the brush.
	var new_brush = {}

	# Populate the dictionary with values based on the global brush variables.
	# We will override these as needed if the brush is a rectange or circle.
	new_brush.brush_type = type
	new_brush.brush_pos = mouse_pos
	new_brush.brush_shape = brush_shape
	new_brush.brush_size = brush_size
	new_brush.brush_color = brush_color

	# If the new bursh is a rectangle shape, we need to calculate the top left corner of the rectangle and the
	# bottom right corner of the rectangle.
	if type == BrushModes.RECTANGLE_SHAPE:
		var TL_pos = Vector2()
		var BR_pos = Vector2()

		# Figure out the left and right positions of the corners and assign them to the proper variable.
		if mouse_pos.x < mouse_click_start_pos.x:
			TL_pos.x = mouse_pos.x
			BR_pos.x = mouse_click_start_pos.x
		else:
			TL_pos.x = mouse_click_start_pos.x
			BR_pos.x = mouse_pos.x

		# Figure out the top and bottom positions of the corners and assign them to the proper variable.
		if mouse_pos.y < mouse_click_start_pos.y:
			TL_pos.y = mouse_pos.y
			BR_pos.y = mouse_click_start_pos.y
		else:
			TL_pos.y = mouse_click_start_pos.y
			BR_pos.y = mouse_pos.y

		# Assign the positions to the brush.
		new_brush.brush_pos = TL_pos
		new_brush.brush_shape_rect_pos_BR = BR_pos

	# If the brush isa circle shape, then we need to calculate the radius of the circle.
	if type == BrushModes.CIRCLE_SHAPE:
		# Get the center point inbetween the mouse position and the position of the mouse when we clicked.
		var center_pos = Vector2((mouse_pos.x + mouse_click_start_pos.x) / 2, (mouse_pos.y + mouse_click_start_pos.y) / 2)
		# Assign the brush position to the center point, and calculate the radius of the circle using the distance from
		# the center to the top/bottom positon of the mouse.
		new_brush.brush_pos = center_pos
		new_brush.brush_shape_circle_radius = center_pos.distance_to(Vector2(center_pos.x, mouse_pos.y))

	# Add the brush and update/draw all of the brushes.
	brush_data_list.append(new_brush)
	update()


func _draw():
	# Go through all of the brushes in brush_data_list.
	for brush in brush_data_list:
		match brush.brush_type:
			BrushModes.PENCIL:
				# If the brush shape is a rectangle, then we need to make a Rect2 so we can use draw_rect.
				# Draw_rect draws a rectagle at the top left corner, using the scale for the size.
				# So we offset the position by half of the brush size so the rectangle's center is at mouse position.
				if brush.brush_shape == BrushShapes.RECTANGLE:
					var rect = Rect2(brush.brush_pos - Vector2(brush.brush_size / 2, brush.brush_size / 2), Vector2(brush.brush_size, brush.brush_size))
					draw_rect(rect, brush.brush_color)
				# If the brush shape is a circle, then we draw a circle at the mouse position,
				# making the radius half of brush size (so the circle is brush size pixels in diameter).
				elif brush.brush_shape == BrushShapes.CIRCLE:
					draw_circle(brush.brush_pos, brush.brush_size / 2, brush.brush_color)
			BrushModes.ERASER:
				# NOTE: this is a really cheap way of erasing that isn't really erasing!
				# However, this gives similar results in a fairy simple way!

				# Erasing works exactly the same was as pencil does for both the rectangle shape and the circle shape,
				# but instead of using brush.brush_color, we instead use bg_color instead.
				if brush.brush_shape == BrushShapes.RECTANGLE:
					var rect = Rect2(brush.brush_pos - Vector2(brush.brush_size / 2, brush.brush_size / 2), Vector2(brush.brush_size, brush.brush_size))
					draw_rect(rect, bg_color)
				elif brush.brush_shape == BrushShapes.CIRCLE:
					draw_circle(brush.brush_pos, brush.brush_size / 2, bg_color)
			BrushModes.RECTANGLE_SHAPE:
				# We make a Rect2 with the postion at the top left. To get the size we take the bottom right position
				# and subtract the top left corner's position.
				var rect = Rect2(brush.brush_pos, brush.brush_shape_rect_pos_BR - brush.brush_pos)
				draw_rect(rect, brush.brush_color)
			BrushModes.CIRCLE_SHAPE:
				# We simply draw a circle using stored in brush.
				draw_circle(brush.brush_pos, brush.brush_shape_circle_radius, brush.brush_color)


func save_picture(path):
	# Wait until the frame has finished before getting the texture.
	yield(VisualServer, "frame_post_draw")

	# Get the viewport image.
	var img = get_viewport().get_texture().get_data()
	# Crop the image so we only have canvas area.
	var cropped_image = img.get_rect(Rect2(TL_node.global_position, IMAGE_SIZE))
	# Flip the image on the Y-axis (it's flipped upside down by default).
	cropped_image.flip_y()

	# Save the image with the passed in path we got from the save dialog.
	cropped_image.save_png(path)
