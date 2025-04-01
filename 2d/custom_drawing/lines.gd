# This is a `@tool` script so that the custom 2D drawing can be seen in the editor.
@tool
extends Panel

var use_antialiasing := false


func _draw() -> void:
	var margin := Vector2(200, 50)

	# Line width of `-1.0` is only usable with draw antialiasing disabled,
	# as it uses hardware line drawing as opposed to polygon-based line drawing.
	# Automatically use polygon-based line drawing when needed to avoid runtime warnings.
	# We also use a line width of `0.5` instead of `1.0` to better match the appearance
	# of non-antialiased line drawing, as draw antialiasing tends to make lines look thicker.
	var line_width_thin := 0.5 if use_antialiasing else -1.0

	# Make thick lines 1 pixel thinner when draw antialiasing is enabled,
	# as draw antialiasing tends to make lines look thicker.
	var antialiasing_width_offset := 1.0 if use_antialiasing else 0.0

	var offset := Vector2()
	var line_length := Vector2(140, 35)
	draw_line(margin + offset, margin + offset + line_length, Color.GREEN, line_width_thin, use_antialiasing)
	offset += Vector2(line_length.x + 15, 0)
	draw_line(margin + offset, margin + offset + line_length, Color.GREEN, 2.0 - antialiasing_width_offset, use_antialiasing)
	offset += Vector2(line_length.x + 15, 0)
	draw_line(margin + offset, margin + offset + line_length, Color.GREEN, 6.0 - antialiasing_width_offset, use_antialiasing)
	offset += Vector2(line_length.x + 15, 0)
	draw_dashed_line(margin + offset, margin + offset + line_length, Color.CYAN, line_width_thin, 5.0, true, use_antialiasing)
	offset += Vector2(line_length.x + 15, 0)
	draw_dashed_line(margin + offset, margin + offset + line_length, Color.CYAN, 2.0 - antialiasing_width_offset, 10.0, true, use_antialiasing)
	offset += Vector2(line_length.x + 15, 0)
	draw_dashed_line(margin + offset, margin + offset + line_length, Color.CYAN, 6.0 - antialiasing_width_offset, 15.0, true, use_antialiasing)


	offset = Vector2(40, 120)
	draw_circle(margin + offset, 40, Color.ORANGE, false, line_width_thin, use_antialiasing)

	offset += Vector2(100, 0)
	draw_circle(margin + offset, 40, Color.ORANGE, false, 2.0 - antialiasing_width_offset, use_antialiasing)

	offset += Vector2(100, 0)
	draw_circle(margin + offset, 40, Color.ORANGE, false, 6.0 - antialiasing_width_offset, use_antialiasing)

	# Draw a filled circle. The width parameter is ignored for filled circles (it's set to `-1.0` to avoid warnings).
	# We also reduce the radius by half the antialiasing width offset.
	# Otherwise, the circle becomes very slightly larger when draw antialiasing is enabled.
	offset += Vector2(100, 0)
	draw_circle(margin + offset, 40 - antialiasing_width_offset * 0.5, Color.ORANGE, true, -1.0, use_antialiasing)

	# `draw_set_transform()` is a stateful command: it affects *all* `draw_` methods within this
	# `_draw()` function after it. This can be used to translate, rotate or scale `draw_` methods
	# that don't offer dedicated parameters for this (such as `draw_primitive()` not having a position parameter).
	# To reset back to the initial transform, call `draw_set_transform(Vector2())`.
	#
	# Draw an horizontally stretched circle.
	offset += Vector2(200, 0)
	draw_set_transform(margin + offset, 0.0, Vector2(3.0, 1.0))
	draw_circle(Vector2(), 40, Color.ORANGE, false, line_width_thin, use_antialiasing)
	draw_set_transform(Vector2())

	# Draw a quarter circle (`TAU` represents a full turn in radians).
	const POINT_COUNT_HIGH = 24
	offset = Vector2(0, 200)
	draw_arc(margin + offset, 60, 0, 0.25 * TAU, POINT_COUNT_HIGH, Color.YELLOW, line_width_thin, use_antialiasing)

	offset += Vector2(100, 0)
	draw_arc(margin + offset, 60, 0, 0.25 * TAU, POINT_COUNT_HIGH, Color.YELLOW, 2.0 - antialiasing_width_offset, use_antialiasing)

	offset += Vector2(100, 0)
	draw_arc(margin + offset, 60, 0, 0.25 * TAU, POINT_COUNT_HIGH, Color.YELLOW, 6.0 - antialiasing_width_offset, use_antialiasing)

	# Draw a three quarters of a circle with a low point count, which gives it an angular look.
	const POINT_COUNT_LOW = 7
	offset += Vector2(125, 30)
	draw_arc(margin + offset, 40, -0.25 * TAU, 0.5 * TAU, POINT_COUNT_LOW, Color.YELLOW, line_width_thin, use_antialiasing)

	offset += Vector2(100, 0)
	draw_arc(margin + offset, 40, -0.25 * TAU, 0.5 * TAU, POINT_COUNT_LOW, Color.YELLOW, 2.0 - antialiasing_width_offset, use_antialiasing)

	offset += Vector2(100, 0)
	draw_arc(margin + offset, 40, -0.25 * TAU, 0.5 * TAU, POINT_COUNT_LOW, Color.YELLOW, 6.0 - antialiasing_width_offset, use_antialiasing)

	# Draw an horizontally stretched arc.
	offset += Vector2(200, 0)
	draw_set_transform(margin + offset, 0.0, Vector2(3.0, 1.0))
	draw_arc(Vector2(), 40, -0.25 * TAU, 0.5 * TAU, POINT_COUNT_LOW, Color.YELLOW, line_width_thin, use_antialiasing)
	draw_set_transform(Vector2())
