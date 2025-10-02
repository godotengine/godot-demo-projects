# This is a `@tool` script so that the custom 2D drawing can be seen in the editor.
@tool
extends Panel

var use_antialiasing := false

func _draw() -> void:
	const ICON = preload("res://icon.svg")
	var margin := Vector2(260, 40)

	var offset := Vector2()
	# Draw a texture.
	draw_texture(ICON, margin + offset, Color.WHITE)

	# `draw_set_transform()` is a stateful command: it affects *all* `draw_` methods within this
	# `_draw()` function after it. This can be used to translate, rotate or scale `draw_` methods
	# that don't offer dedicated parameters for this (such as `draw_rect()` not having a rotation parameter).
	# To reset back to the initial transform, call `draw_set_transform(Vector2())`.
	#
	# Draw a rotated texture at half the scale of its original pixel size.
	offset += Vector2(200, 20)
	draw_set_transform(margin + offset, deg_to_rad(45.0), Vector2(0.5, 0.5))
	draw_texture(ICON, Vector2(), Color.WHITE)
	draw_set_transform(Vector2())

	# Draw a stretched texture. In this example, the icon is 128×128 so it will be drawn at 2× scale.
	offset += Vector2(70, -20)
	draw_texture_rect(
			ICON,
			Rect2(margin + offset, Vector2(256, 256)),
			false,
			Color.GREEN
	)


	# Draw a tiled texture. In this example, the icon is 128×128 so it will be drawn twice on each axis.
	offset += Vector2(270, 0)
	draw_texture_rect(
			ICON,
			Rect2(margin + offset, Vector2(256, 256)),
			true,
			Color.GREEN
	)

	offset = Vector2(0, 300)

	draw_texture_rect_region(
			ICON,
			Rect2(margin + offset, Vector2(128, 128)),
			Rect2(Vector2(32, 32), Vector2(64, 64)),
			Color.VIOLET
	)

	# Draw a tiled texture from a region that is larger than the original texture size (128×128).
	# Transposing is enabled, which will rotate the image by 90 degrees counter-clockwise.
	# (For more advanced transforms, use `draw_set_transform()` before calling `draw_texture_rect_region()`.)
	#
	# For tiling to work with this approach, the CanvasItem in which this `_draw()` method is called
	# must have its Repeat property set to Enabled in the inspector.
	offset += Vector2(140, 0)
	draw_texture_rect_region(
			ICON,
			Rect2(margin + offset, Vector2(128, 128)),
			Rect2(Vector2(), Vector2(512, 512)),
			Color.VIOLET,
			true
	)
