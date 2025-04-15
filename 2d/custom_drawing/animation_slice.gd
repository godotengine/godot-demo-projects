extends Control

var use_antialiasing := false

func _draw() -> void:
	var margin := Vector2(240, 70)
	var offset := Vector2(0, 150)
	# This is an example of using draw commands to create animations.
	# For "continuous" animations, you can use a timer within `_draw()` and call `queue_redraw()`
	# in `_process()` to redraw every frame.
	# Animation length in seconds. The animation will loop after the specified duration.
	const ANIMATION_LENGTH = 2.0
	# 5 frames per second.
	const ANIMATION_FRAMES = 10

	# Declare an animation frame with randomized rotation and color for each frame.
	# `draw_animation_slice()` makes it so the following draw commands are only visible
	# on screen when the current time is within the animation slice.
	# NOTE: Pause does not affect animations drawn by `draw_animation_slice()`
	# (they will keep playing).
	for frame in ANIMATION_FRAMES:
		# `remap()` is useful to determine the time slice in which a frame is visible.
		# For example, on the 2nd frame, `slice_begin` is `0.2` and `slice_end` is `0.4`.
		var slice_begin := remap(frame, 0, ANIMATION_FRAMES, 0, ANIMATION_LENGTH)
		var slice_end := remap(frame + 1, 0, ANIMATION_FRAMES, 0, ANIMATION_LENGTH)
		draw_animation_slice(ANIMATION_LENGTH, slice_begin, slice_end)
		draw_set_transform(margin + offset, deg_to_rad(randf_range(-5.0, 5.0)))
		draw_rect(
			Rect2(Vector2(), Vector2(100, 50)),
			Color.from_hsv(randf(), 0.4, 1.0),
			true,
			-1.0,
			use_antialiasing
	)

	draw_end_animation()
