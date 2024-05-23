extends Control

# This script demonstrates how to alter StyleBoxes at runtime.
# Custom theme item properties aren't considered Object properties per se.
# This means that you should use `add_theme_stylebox_override("normal", ...)`
# instead of `set("custom_styles/normal", ...)`.

@onready var label: Label = $Panel/MarginContainer/VBoxContainer/Label
@onready var button: Button = $Panel/MarginContainer/VBoxContainer/Button
@onready var button2: Button = $Panel/MarginContainer/VBoxContainer/Button2
@onready var reset_all_button: Button = $Panel/MarginContainer/VBoxContainer/ResetAllButton

func _ready() -> void:
	# Focus the first button automatically for keyboard/controller-friendly navigation.
	button.grab_focus()


func _on_button_pressed() -> void:
	# We have to modify the normal, hover and pressed styleboxes all at once
	# to get a correct appearance when the button is hovered or pressed.
	# We can't use a single StyleBox for all of them as these have different
	# background colors.
	var new_stylebox_normal: StyleBoxFlat = button.get_theme_stylebox("normal").duplicate()
	new_stylebox_normal.border_color = Color(1, 1, 0)
	var new_stylebox_hover: StyleBoxFlat = button.get_theme_stylebox("hover").duplicate()
	new_stylebox_hover.border_color = Color(1, 1, 0)
	var new_stylebox_pressed: StyleBoxFlat = button.get_theme_stylebox("pressed").duplicate()
	new_stylebox_pressed.border_color = Color(1, 1, 0)

	button.add_theme_stylebox_override("normal", new_stylebox_normal)
	button.add_theme_stylebox_override("hover", new_stylebox_hover)
	button.add_theme_stylebox_override("pressed", new_stylebox_pressed)

	label.add_theme_color_override("font_color", Color(1, 1, 0.375))


func _on_button2_pressed() -> void:
	var new_stylebox_normal: StyleBoxFlat = button2.get_theme_stylebox("normal").duplicate()
	new_stylebox_normal.border_color = Color(0, 1, 0.5)
	var new_stylebox_hover: StyleBoxFlat = button2.get_theme_stylebox("hover").duplicate()
	new_stylebox_hover.border_color = Color(0, 1, 0.5)
	var new_stylebox_pressed: StyleBoxFlat = button2.get_theme_stylebox("pressed").duplicate()
	new_stylebox_pressed.border_color = Color(0, 1, 0.5)

	button2.add_theme_stylebox_override("normal", new_stylebox_normal)
	button2.add_theme_stylebox_override("hover", new_stylebox_hover)
	button2.add_theme_stylebox_override("pressed", new_stylebox_pressed)

	label.add_theme_color_override("font_color", Color(0.375, 1, 0.75))


func _on_reset_all_button_pressed() -> void:
	button.remove_theme_stylebox_override("normal")
	button.remove_theme_stylebox_override("hover")
	button.remove_theme_stylebox_override("pressed")

	button2.remove_theme_stylebox_override("normal")
	button2.remove_theme_stylebox_override("hover")
	button2.remove_theme_stylebox_override("pressed")

	label.remove_theme_color_override("font_color")
