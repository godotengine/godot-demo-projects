extends Control

func _input(event: InputEvent) -> void:
	if event.is_action_pressed(&"toggle_msdf_font"):
		if %FontLabel.get_theme_font("font").multichannel_signed_distance_field:
			%FontLabel.add_theme_font_override("font", preload("res://montserrat_semibold.ttf"))
		else:
			%FontLabel.add_theme_font_override("font", preload("res://montserrat_semibold_msdf.ttf"))

		update_label()


func update_label() -> void:
	%FontMode.text = "Font rendering: %s" % (
			"MSDF" if %FontLabel.get_theme_font("font").multichannel_signed_distance_field else "Traditional"
	)


func _on_outline_size_value_changed(value: float) -> void:
	%FontLabel.add_theme_constant_override("outline_size", int(value))
	%Value.text = str(value)
