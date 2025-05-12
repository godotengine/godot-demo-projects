# This is a `@tool` script so that the custom 2D drawing can be seen in the editor.
@tool
extends Panel

var use_antialiasing := false


func _draw() -> void:
	var font := get_theme_default_font()
	const FONT_SIZE = 24
	const STRING = "Hello world!"
	var margin := Vector2(240, 60)

	var offset := Vector2()
	var advance := Vector2()
	for character in STRING:
		# Draw each character with a random pastel color.
		# Notice how the advance calculated on the loop's previous iteration is used as an offset here.
		draw_char(font, margin + offset + advance, character, FONT_SIZE, Color.from_hsv(randf(), 0.4, 1.0))

		# Get the glyph index of the character we've just drawn, so we can retrieve the glyph advance.
		# This determines the spacing between glyphs so the next character is positioned correctly.
		var glyph_idx := TextServerManager.get_primary_interface().font_get_glyph_index(
					get_theme_default_font().get_rids()[0],
					FONT_SIZE,
					character.unicode_at(0),
					0
		)
		advance.x += TextServerManager.get_primary_interface().font_get_glyph_advance(
				get_theme_default_font().get_rids()[0],
				FONT_SIZE,
				glyph_idx
		).x

	offset += Vector2(0, 32)
	# When drawing a font outline, it must be drawn *before* the main text.
	# This way, the outline appears behind the main text.
	draw_string_outline(
			font,
			margin + offset,
			STRING,
			HORIZONTAL_ALIGNMENT_LEFT,
			-1,
			FONT_SIZE,
			12,
			Color.ORANGE.darkened(0.6)
	)
	# NOTE: Use `draw_multiline_string()` to draw strings that contain line breaks (`\n`) or with
	# automatic line wrapping based on the specified width.
	# A width of `-1` is used here, which means "no limit". If width is limited, the end of the string
	# will be cut off if it doesn't fit within the specified width.
	draw_string(
			font,
			margin + offset,
			STRING,
			HORIZONTAL_ALIGNMENT_LEFT,
			-1,
			FONT_SIZE,
			Color.YELLOW
	)
