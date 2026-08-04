# This is a `@tool` script so that the custom 2D drawing can be seen in the editor.
@tool
extends Panel

var use_antialiasing: bool = false


func _draw() -> void:
	var margin := Vector2(200, 50)

	# Line width of `-1.0` is only usable with draw antialiasing disabled,
	# as it uses hardware line drawing as opposed to polygon-based line drawing.
	# Automatically use polygon-based line drawing when needed to avoid runtime warnings.
	# We also use a line width of `0.5` instead of `1.0` to better match the appearance
	# of non-antialiased line drawing, as draw antialiasing tends to make lines look thicker.
	var line_width_thin := 0.5 if use_antialiasing else -1.0

	var offset := Vector2()
	var line_length := Vector2(140, 35)
	draw_line(margin + offset, margin + offset + line_length, Color.GREEN, line_width_thin, use_antialiasing)
	offset += Vector2(line_length.x + 15, 0)
	draw_line(margin + offset, margin + offset + line_length, Color.GREEN, 2.0, use_antialiasing)
	offset += Vector2(line_length.x + 15, 0)
	draw_line(margin + offset, margin + offset + line_length, Color.GREEN, 6.0, use_antialiasing)
	offset += Vector2(line_length.x + 15, 0)
	draw_dashed_line(margin + offset, margin + offset + line_length, Color.CYAN, line_width_thin, 5.0, true, use_antialiasing)
	offset += Vector2(line_length.x + 15, 0)
	draw_dashed_line(margin + offset, margin + offset + line_length, Color.CYAN, 2.0, 10.0, true, use_antialiasing)
	offset += Vector2(line_length.x + 15, 0)
	draw_dashed_line(margin + offset, margin + offset + line_length, Color.CYAN, 6.0, 15.0, true, use_antialiasing)


	offset = Vector2(40, 170)
	draw_circle(margin + offset, 40, Color.ORANGE, false, line_width_thin, use_antialiasing)

	offset += Vector2(100, 0)
	draw_circle(margin + offset, 40, Color.ORANGE, false, 2.0, use_antialiasing)

	offset += Vector2(100, 0)
	draw_circle(margin + offset, 40, Color.ORANGE, false, 6.0, use_antialiasing)

	# Draw a filled circle. The width parameter is ignored for filled circles (it's set to `-1.0` to avoid warnings).
	offset += Vector2(100, 0)
	draw_circle(margin + offset, 40 * 0.5, Color.ORANGE, true, -1.0, use_antialiasing)

	# Draw an ellipse (oval circle).
	offset += Vector2(200, 0)
	draw_ellipse(margin + offset, 120, 40, Color.ORANGE_RED, false, line_width_thin, use_antialiasing)

	# Draw a quarter circle (`TAU` represents a full turn in radians).
	const POINT_COUNT_HIGH = 24
	offset = Vector2(0, 300)
	draw_arc(margin + offset, 60, 0, 0.25 * TAU, POINT_COUNT_HIGH, Color.YELLOW, line_width_thin, use_antialiasing)

	offset += Vector2(100, 0)
	draw_arc(margin + offset, 60, 0, 0.25 * TAU, POINT_COUNT_HIGH, Color.YELLOW, 2.0, use_antialiasing)

	offset += Vector2(100, 0)
	draw_arc(margin + offset, 60, 0, 0.25 * TAU, POINT_COUNT_HIGH, Color.YELLOW, 6.0, use_antialiasing)

	# Draw three quarters of a circle with a low point count, which gives it an angular look.
	const POINT_COUNT_LOW = 7
	offset += Vector2(125, 30)
	draw_arc(margin + offset, 40, -0.25 * TAU, 0.5 * TAU, POINT_COUNT_LOW, Color.YELLOW, line_width_thin, use_antialiasing)

	offset += Vector2(100, 0)
	draw_arc(margin + offset, 40, -0.25 * TAU, 0.5 * TAU, POINT_COUNT_LOW, Color.YELLOW, 2.0, use_antialiasing)

	offset += Vector2(100, 0)
	draw_arc(margin + offset, 40, -0.25 * TAU, 0.5 * TAU, POINT_COUNT_LOW, Color.YELLOW, 6.0, use_antialiasing)

	# Draw three quarters of an ellipse (oval) with a low point count, which gives it an angular look.
	offset += Vector2(230, 0)
	draw_ellipse_arc(margin + offset, 120, 40, -0.25 * TAU, 0.5 * TAU, POINT_COUNT_LOW, Color.PALE_GREEN, line_width_thin, use_antialiasing)
