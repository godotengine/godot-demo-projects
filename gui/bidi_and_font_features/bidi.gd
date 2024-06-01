extends Control

@onready var variable_font_variation: FontVariation = $"TabContainer/Variable fonts/VariableFontPreview".get_theme_font("font")

func _ready() -> void:
	var tree: Tree = $"TabContainer/Text direction/Tree"
	var root := tree.create_item()
	tree.set_hide_root(true)
	var first := tree.create_item(root)
	first.set_text(0, "רֵאשִׁית")
	var second := tree.create_item(first)
	second.set_text(0, "שֵׁנִי")
	var third := tree.create_item(second)
	third.set_text(0, "שְׁלִישִׁי")
	var fourth := tree.create_item(third)
	fourth.set_text(0, "fourth")

func _on_Tree_item_selected() -> void:
	var tree: Tree = $"TabContainer/Text direction/Tree"
	var path := ""
	var item := tree.get_selected()
	while item != null:
		path = item.get_text(0) + "/" + path
		item = item.get_parent()
	$"TabContainer/Text direction/LineEditST".text = path
	$"TabContainer/Text direction/LineEditNoST".text = path

func _on_LineEditCustomSTDst_text_changed(new_text: String) -> void:
	$"TabContainer/Text direction/LineEditCustomSTSource".text = new_text

func _on_LineEditCustomSTSource_text_changed(new_text: String) -> void:
	$"TabContainer/Text direction/LineEditCustomSTDst".text = new_text

func _on_LineEditCustomSTDst_tree_entered() -> void:
	# Refresh text to apply custom script once it's loaded.
	$"TabContainer/Text direction/LineEditCustomSTDst".text = $"TabContainer/Text direction/LineEditCustomSTSource".text


func _on_variable_size_value_changed(value: float) -> void:
	$"TabContainer/Variable fonts/Variables/Size/Value".text = str(value)
	# This is also available on non-variable fonts.
	$"TabContainer/Variable fonts/VariableFontPreview".add_theme_font_size_override("font_size", value)


func _on_variable_weight_value_changed(value: float) -> void:
	$"TabContainer/Variable fonts/Variables/Weight/Value".text = str(value)
	# Workaround to make the variable font axis value effective. This requires duplicating the dictionary.
	var dict := variable_font_variation.variation_opentype.duplicate()
	dict["weight"] = value
	variable_font_variation.variation_opentype = dict


func _on_variable_slant_value_changed(value: float) -> void:
	$"TabContainer/Variable fonts/Variables/Slant/Value".text = str(value)
	# Workaround to make the variable font axis value effective. This requires duplicating the dictionary.
	var dict := variable_font_variation.variation_opentype.duplicate()
	dict["slant"] = value
	variable_font_variation.variation_opentype = dict


func _on_variable_cursive_toggled(button_pressed: bool) -> void:
	$"TabContainer/Variable fonts/Variables/Cursive".button_pressed = button_pressed
	# Workaround to make the variable font axis value effective. This requires duplicating the dictionary.
	var dict := variable_font_variation.variation_opentype.duplicate()
	dict["custom_CRSV"] = int(button_pressed)
	variable_font_variation.variation_opentype = dict


func _on_variable_casual_toggled(button_pressed: bool) -> void:
	$"TabContainer/Variable fonts/Variables/Casual".button_pressed = button_pressed
	# Workaround to make the variable font axis value effective. This requires duplicating the dictionary.
	var dict := variable_font_variation.variation_opentype.duplicate()
	dict["custom_CASL"] = int(button_pressed)
	variable_font_variation.variation_opentype = dict


func _on_variable_monospace_toggled(button_pressed: bool) -> void:
	$"TabContainer/Variable fonts/Variables/Monospace".button_pressed = button_pressed
	# Workaround to make the variable font axis value effective. This requires duplicating the dictionary.
	var dict := variable_font_variation.variation_opentype.duplicate()
	dict["custom_MONO"] = int(button_pressed)
	variable_font_variation.variation_opentype = dict


func _on_system_font_value_text_changed(new_text: String) -> void:
	for label: Label in [
		$"TabContainer/System fonts/VBoxContainer/SansSerif/Value",
		$"TabContainer/System fonts/VBoxContainer/Serif/Value",
		$"TabContainer/System fonts/VBoxContainer/Monospace/Value",
		$"TabContainer/System fonts/VBoxContainer/Cursive/Value",
		$"TabContainer/System fonts/VBoxContainer/Fantasy/Value",
		$"TabContainer/System fonts/VBoxContainer/Custom/Value"
	]:
		label.text = new_text


func _on_system_font_weight_value_changed(value: float) -> void:
	$"TabContainer/System fonts/Weight/Value".text = str(value)
	for label: Label in [
		$"TabContainer/System fonts/VBoxContainer/SansSerif/Value",
		$"TabContainer/System fonts/VBoxContainer/Serif/Value",
		$"TabContainer/System fonts/VBoxContainer/Monospace/Value",
		$"TabContainer/System fonts/VBoxContainer/Cursive/Value",
		$"TabContainer/System fonts/VBoxContainer/Fantasy/Value",
		$"TabContainer/System fonts/VBoxContainer/Custom/Value"
	]:
		var system_font: SystemFont = label.get_theme_font("font")
		system_font.font_weight = int(value)

func _on_system_font_italic_toggled(button_pressed: bool) -> void:
	for label: Label in [
		$"TabContainer/System fonts/VBoxContainer/SansSerif/Value",
		$"TabContainer/System fonts/VBoxContainer/Serif/Value",
		$"TabContainer/System fonts/VBoxContainer/Monospace/Value",
		$"TabContainer/System fonts/VBoxContainer/Cursive/Value",
		$"TabContainer/System fonts/VBoxContainer/Fantasy/Value",
		$"TabContainer/System fonts/VBoxContainer/Custom/Value"
	]:
		var system_font: SystemFont = label.get_theme_font("font")
		system_font.font_italic = button_pressed


func _on_system_font_name_text_changed(new_text: String) -> void:
	var system_font: SystemFont = $"TabContainer/System fonts/VBoxContainer/Custom/FontName".get_theme_font("font")
	system_font.font_names[0] = new_text




