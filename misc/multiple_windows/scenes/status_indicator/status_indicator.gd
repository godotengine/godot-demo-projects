extends StatusIndicator

@onready var popup_menu: PopupMenu = get_node(menu)

func _ready() -> void:
	popup_menu.prefer_native_menu = true
	popup_menu.add_item("Quit")
	popup_menu.index_pressed.connect(_on_popup_menu_index_pressed)
	pressed.connect(_on_pressed)


# Isn't being called on right mouse button because menu is set.
func _on_pressed(mouse_button: int, _mouse_position: Vector2i) -> void:
	if mouse_button == MOUSE_BUTTON_LEFT:
		var window: Window = get_window()
		if window.mode == Window.Mode.MODE_MINIMIZED:
			window.mode = Window.Mode.MODE_WINDOWED
		window.grab_focus()


func _on_popup_menu_index_pressed(index: int) -> void:
	match index:
		0:
			get_tree().root.propagate_notification(NOTIFICATION_WM_CLOSE_REQUEST)
			get_tree().quit()
