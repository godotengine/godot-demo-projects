class_name OptionMenu
extends MenuButton

signal option_selected(item_path: String)
signal option_changed(item_path: String, checked: bool)


func add_menu_item(item_path: String, checkbox: bool = false, checked: bool = false, radio: bool = false) -> void:
	var path_elements := item_path.split("/", false)
	var path_element_count := path_elements.size()
	assert(path_element_count > 0)

	var path := ""
	var popup := get_popup()
	for element_index in range(path_element_count - 1):
		var popup_label := path_elements[element_index]
		path += popup_label + "/"
		popup = _add_popup(popup, path, popup_label)

	var label := path_elements[path_element_count - 1]
	if radio:
		popup.add_radio_check_item(label)
		popup.set_item_checked(popup.get_item_count() - 1, checked)
	elif checkbox:
		popup.add_check_item(label)
		popup.set_item_checked(popup.get_item_count() - 1, checked)
	else:
		popup.add_item(label)


func _add_item(parent_popup: PopupMenu, label: String) -> void:
	parent_popup.add_item(label)


func _add_popup(parent_popup: PopupMenu, path: String, label: String) -> PopupMenu:
	if parent_popup.has_node(label):
		var popup_node := parent_popup.get_node(label)
		var new_popup_menu: PopupMenu = popup_node
		assert(new_popup_menu)
		return new_popup_menu

	var popup_menu := PopupMenu.new()
	popup_menu.name = label
	popup_menu.hide_on_checkable_item_selection = false

	parent_popup.add_child(popup_menu)
	parent_popup.add_submenu_item(label, label)

	popup_menu.index_pressed.connect(_on_item_pressed.bind(popup_menu, path))

	return popup_menu


func _on_item_pressed(item_index: int, popup_menu: PopupMenu, path: String) -> void:
	var item_path := path + popup_menu.get_item_text(item_index)

	if popup_menu.is_item_radio_checkable(item_index):
		var checked := popup_menu.is_item_checked(item_index)
		if not checked:
			popup_menu.set_item_checked(item_index, true)
			for other_index in range(popup_menu.get_item_count()):
				if other_index != item_index:
					popup_menu.set_item_checked(other_index, false)
			option_selected.emit(item_path)
	elif popup_menu.is_item_checkable(item_index):
		var checked := not popup_menu.is_item_checked(item_index)
		popup_menu.set_item_checked(item_index, checked)
		option_changed.emit(item_path, checked)
	else:
		option_selected.emit(item_path)
