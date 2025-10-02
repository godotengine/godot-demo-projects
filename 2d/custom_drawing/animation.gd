# This is a `@tool` script so that the custom 2D drawing can be seen in the editor.
@tool
extends Panel

var use_antialiasing := false

var time := 0.0

func _process(delta: float) -> void:
	# Increment a counter variable that we use in `_draw()`.
	time += delta
	# Force redrawing on every processed frame, so that the animation can visibly progress.
	# Only do this when the node is visible in tree, so that we don't force continuous redrawing
	# when not needed (low-processor usage mode is enabled in this demo).
	if is_visible_in_tree():
		queue_redraw()


func _draw() -> void:
	var margin := Vector2(240, 70)
	var offset := Vector2()

	# Line width of `-1.0` is only usable with draw antialiasing disabled,
	# as it uses hardware line drawing as opposed to polygon-based line drawing.
	# Automatically use polygon-based line drawing when needed to avoid runtime warnings.
	# We also use a line width of `0.5` instead of `1.0` to better match the appearance
	# of non-antialiased line drawing, as draw antialiasing tends to make lines look thicker.
	var line_width_thin := 0.5 if use_antialiasing else -1.0

	# Draw an animated arc to simulate a circular progress bar.
	# The start angle is set so the arc starts from the top.
	const POINT_COUNT = 48
	var progress := wrapf(time, 0.0, 1.0)
	draw_arc(
			margin + offset,
			50.0,
			0.75 * TAU,
			(0.75 + progress) * TAU,
			POINT_COUNT,
			Color.MEDIUM_AQUAMARINE,
			line_width_thin,
			use_antialiasing
	)
