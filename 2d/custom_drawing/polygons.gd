# This is a `@tool` script so that the custom 2D drawing can be seen in the editor.
@tool
extends Panel

var use_antialiasing := false


func _draw() -> void:
	var margin := Vector2(240, 40)

	# Line width of `-1.0` is only usable with draw antialiasing disabled,
	# as it uses hardware line drawing as opposed to polygon-based line drawing.
	# Automatically use polygon-based line drawing when needed to avoid runtime warnings.
	# We also use a line width of `0.5` instead of `1.0` to better match the appearance
	# of non-antialiased line drawing, as draw antialiasing tends to make lines look thicker.
	var line_width_thin := 0.5 if use_antialiasing else -1.0

	# Make thick lines 1 pixel thinner when draw antialiasing is enabled,
	# as draw antialiasing tends to make lines look thicker.
	var antialiasing_width_offset := 1.0 if use_antialiasing else 0.0

	var points := PackedVector2Array([
		Vector2(0, 0),
		Vector2(0, 60),
		Vector2(60, 90),
		Vector2(60, 0),
		Vector2(40, 25),
		Vector2(10, 40),
	])
	var colors := PackedColorArray([
		Color.WHITE,
		Color.RED,
		Color.GREEN,
		Color.BLUE,
		Color.MAGENTA,
		Color.MAGENTA,
	])

	var offset := Vector2()
	# `draw_set_transform()` is a stateful command: it affects *all* `draw_` methods within this
	# `_draw()` function after it. This can be used to translate, rotate or scale `draw_` methods
	# that don't offer dedicated parameters for this (such as `draw_primitive()` not having a position parameter).
	# To reset back to the initial transform, call `draw_set_transform(Vector2())`.
	draw_set_transform(margin + offset)
	draw_primitive(points.slice(0, 1), colors.slice(0, 1), PackedVector2Array())

	offset += Vector2(90, 0)
	draw_set_transform(margin + offset)
	draw_primitive(points.slice(0, 2), colors.slice(0, 2), PackedVector2Array())

	offset += Vector2(90, 0)
	draw_set_transform(margin + offset)
	draw_primitive(points.slice(0, 3), colors.slice(0, 3), PackedVector2Array())

	offset += Vector2(90, 0)
	draw_set_transform(margin + offset)
	draw_primitive(points.slice(0, 4), colors.slice(0, 4), PackedVector2Array())

	# Draw a polygon with multiple colors that are interpolated between each point.
	# Colors are specified in the same order as points' positions, but in a different array.
	offset = Vector2(0, 120)
	draw_set_transform(margin + offset)
	draw_polygon(points, colors)

	# Draw a polygon with a single color. Only a points array is needed in this case.
	offset += Vector2(90, 0)
	draw_set_transform(margin + offset)
	draw_colored_polygon(points, Color.YELLOW)

	# Draw a polygon-based line. Each segment is connected to the previous one, which means
	# `draw_polyline()` always draws a contiguous line.
	offset = Vector2(0, 240)
	draw_set_transform(margin + offset)
	draw_polyline(points, Color.SKY_BLUE, line_width_thin, use_antialiasing)

	offset += Vector2(90, 0)
	draw_set_transform(margin + offset)
	draw_polyline(points, Color.SKY_BLUE, 2.0 - antialiasing_width_offset, use_antialiasing)

	offset += Vector2(90, 0)
	draw_set_transform(margin + offset)
	draw_polyline(points, Color.SKY_BLUE, 6.0 - antialiasing_width_offset, use_antialiasing)

	offset += Vector2(90, 0)
	draw_set_transform(margin + offset)
	draw_polyline_colors(points, colors, line_width_thin, use_antialiasing)

	offset += Vector2(90, 0)
	draw_set_transform(margin + offset)
	draw_polyline_colors(points, colors, 2.0 - antialiasing_width_offset, use_antialiasing)

	offset += Vector2(90, 0)
	draw_set_transform(margin + offset)
	draw_polyline_colors(points, colors, 6.0 - antialiasing_width_offset, use_antialiasing)

	# Draw multiple lines in a single draw command. Unlike `draw_polyline()`,
	# lines are not connected to the last segment.
	# This is faster than calling `draw_line()` several times and should be preferred
	# when drawing dozens of lines or more at once.
	offset = Vector2(0, 360)
	draw_set_transform(margin + offset)
	draw_multiline(points, Color.SKY_BLUE, line_width_thin, use_antialiasing)

	offset += Vector2(90, 0)
	draw_set_transform(margin + offset)
	draw_multiline(points, Color.SKY_BLUE, 2.0 - antialiasing_width_offset, use_antialiasing)

	offset += Vector2(90, 0)
	draw_set_transform(margin + offset)
	draw_multiline(points, Color.SKY_BLUE, 6.0 - antialiasing_width_offset, use_antialiasing)

	# `draw_multiline_colors()` makes it possible to draw lines of different colors in a single
	# draw command, although gradients are not possible this way (unlike `draw_polygon()` and `draw_polyline()`).
	# This means the number of supplied colors must be equal to the number of segments, which means
	# we have to only pass a subset of the colors array in this example.
	offset += Vector2(90, 0)
	draw_set_transform(margin + offset)
	draw_multiline_colors(points, colors.slice(0, 3), line_width_thin, use_antialiasing)

	offset += Vector2(90, 0)
	draw_set_transform(margin + offset)
	draw_multiline_colors(points, colors.slice(0, 3), 2.0 - antialiasing_width_offset, use_antialiasing)

	offset += Vector2(90, 0)
	draw_set_transform(margin + offset)
	draw_multiline_colors(points, colors.slice(0, 3), 6.0 - antialiasing_width_offset, use_antialiasing)
