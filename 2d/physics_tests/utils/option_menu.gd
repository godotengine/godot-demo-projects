class_name OptionMenu
extends MenuButton


signal option_selected(item_path)


func add_menu_item(item_path):
	var path_elements = item_path.split("/", false)
	var path_element_count = path_elements.size()
	assert(path_element_count > 0)

	var path = ""
	var popup = get_popup()
	for element_index in path_element_count - 1:
		var popup_label = path_elements[element_index]
		path += popup_label + "/"
		popup = _add_popup(popup, path, popup_label)

	_add_item(popup, path_elements[path_element_count - 1])


func _add_item(parent_popup, label):
	parent_popup.add_item(label)


func _add_popup(parent_popup, path, label):
	if parent_popup.has_node(label):
		var popup_node = parent_popup.get_node(label)
		var popup_menu = popup_node as PopupMenu
		assert(popup_menu)
		return popup_menu

	var popup_menu = PopupMenu.new()
	popup_menu.name = label

	parent_popup.add_child(popup_menu)
	parent_popup.add_submenu_item(label, label)

	popup_menu.connect("index_pressed", self, "_on_item_pressed", [popup_menu, path])

	return popup_menu


func _on_item_pressed(item_index, popup_menu, path):
	var item_path = path + popup_menu.get_item_text(item_index)
	emit_signal("option_selected", item_path)
