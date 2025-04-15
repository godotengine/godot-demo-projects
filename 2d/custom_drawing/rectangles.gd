# This is a `@tool` script so that the custom 2D drawing can be seen in the editor.
@tool
extends Panel

var use_antialiasing := false


func _draw() -> void:
	var margin := Vector2(200, 40)

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
	draw_rect(
			Rect2(margin + offset, Vector2(100, 50)),
			Color.PURPLE,
			false,
			line_width_thin,
			use_antialiasing
	)

	offset += Vector2(120, 0)
	draw_rect(
			Rect2(margin + offset, Vector2(100, 50)),
			Color.PURPLE,
			false,
			2.0 - antialiasing_width_offset,
			use_antialiasing
	)

	offset += Vector2(120, 0)
	draw_rect(
			Rect2(margin + offset, Vector2(100, 50)),
			Color.PURPLE,
			false,
			6.0 - antialiasing_width_offset,
			use_antialiasing
	)

	# Draw a filled rectangle. The width parameter is ignored for filled rectangles (it's set to `-1.0` to avoid warnings).
	# We also reduce the rectangle's size by half the antialiasing width offset.
	# Otherwise, the rectangle becomes very slightly larger when draw antialiasing is enabled.
	offset += Vector2(120, 0)
	draw_rect(
			Rect2(margin + offset, Vector2(100, 50)).grow(-antialiasing_width_offset * 0.5),
			Color.PURPLE,
			true,
			-1.0,
			use_antialiasing
	)

	# `draw_set_transform()` is a stateful command: it affects *all* `draw_` methods within this
	# `_draw()` function after it. This can be used to translate, rotate or scale `draw_` methods
	# that don't offer dedicated parameters for this (such as `draw_rect()` not having a rotation parameter).
	# To reset back to the initial transform, call `draw_set_transform(Vector2())`.
	offset += Vector2(170, 0)
	draw_set_transform(margin + offset, deg_to_rad(22.5))
	draw_rect(
			Rect2(Vector2(), Vector2(100, 50)),
			Color.PURPLE,
			false,
			line_width_thin,
			use_antialiasing
	)
	offset += Vector2(120, 0)
	draw_set_transform(margin + offset, deg_to_rad(22.5))
	draw_rect(
			Rect2(Vector2(), Vector2(100, 50)),
			Color.PURPLE,
			false,
			2.0 - antialiasing_width_offset,
			use_antialiasing
	)
	offset += Vector2(120, 0)
	draw_set_transform(margin + offset, deg_to_rad(22.5))
	draw_rect(
			Rect2(Vector2(), Vector2(100, 50)),
			Color.PURPLE,
			false,
			6.0 - antialiasing_width_offset,
			use_antialiasing
	)

	# `draw_set_transform_matrix()` is a more advanced counterpart of `draw_set_transform()`.
	# It can be used to apply transforms that are not supported by `draw_set_transform()`, such as
	# skewing.
	offset = Vector2(20, 60)
	var custom_transform := get_transform().translated(margin + offset)
	# Perform horizontal skewing (the rectangle will appear "slanted").
	custom_transform.y.x -= 0.5
	draw_set_transform_matrix(custom_transform)
	draw_rect(
		Rect2(Vector2(), Vector2(100, 50)),
		Color.PURPLE,
		false,
		6.0 - antialiasing_width_offset,
		use_antialiasing
	)
	draw_set_transform(Vector2())

	offset = Vector2(0, 250)
	var style_box_flat := StyleBoxFlat.new()
	style_box_flat.set_border_width_all(4)
	style_box_flat.set_corner_radius_all(8)
	style_box_flat.shadow_size = 1
	style_box_flat.shadow_offset = Vector2(4, 4)
	style_box_flat.shadow_color = Color.RED
	style_box_flat.anti_aliasing = use_antialiasing
	draw_style_box(style_box_flat, Rect2(margin + offset, Vector2(100, 50)))

	offset += Vector2(130, 0)
	var style_box_flat_2 := StyleBoxFlat.new()
	style_box_flat_2.draw_center = false
	style_box_flat_2.set_border_width_all(4)
	style_box_flat_2.set_corner_radius_all(8)
	style_box_flat_2.corner_detail = 1
	style_box_flat_2.border_color = Color.GREEN
	style_box_flat_2.anti_aliasing = use_antialiasing
	draw_style_box(style_box_flat_2, Rect2(margin + offset, Vector2(100, 50)))

	offset += Vector2(160, 0)
	var style_box_flat_3 := StyleBoxFlat.new()
	style_box_flat_3.draw_center = false
	style_box_flat_3.set_border_width_all(4)
	style_box_flat_3.set_corner_radius_all(8)
	style_box_flat_3.border_color = Color.CYAN
	style_box_flat_3.shadow_size = 40
	style_box_flat_3.shadow_offset = Vector2()
	style_box_flat_3.shadow_color = Color.CORNFLOWER_BLUE
	style_box_flat_3.anti_aliasing = use_antialiasing
	custom_transform = get_transform().translated(margin + offset)
	# Perform vertical skewing (the rectangle will appear "slanted").
	custom_transform.x.y -= 0.5
	draw_set_transform_matrix(custom_transform)
	draw_style_box(style_box_flat_3, Rect2(Vector2(), Vector2(100, 50)))

	draw_set_transform(Vector2())
