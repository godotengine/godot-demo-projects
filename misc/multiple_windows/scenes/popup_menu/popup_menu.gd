extends PopupMenu

signal option_pressed(option: String)

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	add_item("Normal Item")
	add_multistate_item("Multistate Item", 3, 0)
	add_radio_check_item("Radio Check Item 1")
	add_radio_check_item("Radio Check Item 2")
	add_check_item("Check Item")
	add_separator("Separator")
	add_submenu_item("Submenu", "SubPopupMenu")
	var submenu: PopupMenu = $SubPopupMenu
	submenu.transparent = true
	submenu.add_item("Submenu Item 1")
	submenu.add_item("Submenu Item 2")
	submenu.index_pressed.connect(func(index): option_pressed.emit(submenu.get_item_text(index)))
	index_pressed.connect(_on_index_pressed)


func _on_index_pressed(index: int) -> void:
	if is_item_checkable(index):
		set_item_checked(index, not is_item_checked(index))

	match index:
		2:
			set_item_checked(3, false)
		3:
			set_item_checked(2, false)

	option_pressed.emit(get_item_text(index))
