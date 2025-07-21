extends Control

@onready var window : Window = $Window
@onready var draggable_window : Window = $DraggableWindow
@onready var file_dialog : FileDialog = $FileDialog
@onready var file_dialog_output : TextEdit = $HBoxContainer/VBoxContainer2/FileDialogOutput
@onready var accept_dialog : AcceptDialog = $AcceptDialog
@onready var accept_dialog_output : TextEdit = $HBoxContainer/VBoxContainer2/AcceptOutput
@onready var confirmation_dialog : ConfirmationDialog = $ConfirmationDialog
@onready var confirmation_dialog_output : TextEdit = $HBoxContainer/VBoxContainer2/ConfirmationOutput
@onready var popup : Popup = $Popup
@onready var popup_menu : PopupMenu = $PopupMenu
@onready var popup_menu_output : TextEdit = $HBoxContainer/VBoxContainer3/PopupMenuOutput
@onready var popup_panel : PopupPanel = $PopupPanel
@onready var status_indicator: StatusIndicator = $StatusIndicator


func _on_embed_subwindows_toggled(toggled_on: bool) -> void:
	var hidden_windows: Array[Window] = []
	for child in get_children():
		if child is Window and child.is_visible():
			child.hide()
			hidden_windows.append(child)

	embed_subwindows(toggled_on)
	for _window in hidden_windows:
		_window.show()


func embed_subwindows(state: bool) -> void:
	get_viewport().gui_embed_subwindows = state


func _on_window_button_pressed() -> void:
	window.show()
	window.grab_focus()


func _on_transient_window_toggled(toggled_on: bool) -> void:
	window.transient = toggled_on


func _on_exclusive_window_toggled(toggled_on: bool) -> void:
	window.exclusive = toggled_on


func _on_unresizable_window_toggled(toggled_on: bool) -> void:
	window.unresizable = toggled_on


func _on_borderless_window_toggled(toggled_on: bool) -> void:
	window.borderless = toggled_on


func _on_always_on_top_window_toggled(toggled_on: bool) -> void:
	window.always_on_top = toggled_on


func _on_transparent_window_toggled(toggled_on: bool) -> void:
	window.transparent = toggled_on


func _on_window_title_edit_text_changed(new_text: String) -> void:
	window.title = new_text


func _on_draggable_window_button_pressed() -> void:
	draggable_window.show()
	draggable_window.grab_focus()


func _on_draggable_window_close_pressed() -> void:
	draggable_window.hide()


func _on_bg_draggable_window_toggled(toggled_on: bool) -> void:
	draggable_window.get_node("BG").visible = toggled_on


func _on_passthrough_polygon_item_selected(index: int) -> void:
	match index:
		0:
			draggable_window.mouse_passthrough_polygon = []
		1:
			draggable_window.get_node("PassthroughGenerator").generate_polygon()
		2:
			draggable_window.mouse_passthrough_polygon = [
					Vector2(16, 0), Vector2(16, 128),
					Vector2(116, 128), Vector2(116, 0)]


func _on_file_dialog_button_pressed() -> void:
	file_dialog.show()


func _on_file_dialog_dir_selected(dir: String) -> void:
	file_dialog_output.text = "Directory Path: " + dir


func _on_file_dialog_file_selected(path: String) -> void:
	file_dialog_output.text = "File Path: " + path


func _on_file_dialog_files_selected(paths: PackedStringArray) -> void:
	file_dialog_output.text = "Chosen Paths: " + str(paths)


func _on_file_dialog_item_selected(index: int) -> void:
	match index:
		0:
			file_dialog.file_mode = FileDialog.FILE_MODE_OPEN_FILE
		1:
			file_dialog.file_mode = FileDialog.FILE_MODE_OPEN_FILES
		2:
			file_dialog.file_mode = FileDialog.FILE_MODE_OPEN_DIR
		3:
			file_dialog.file_mode = FileDialog.FILE_MODE_OPEN_ANY
		4:
			file_dialog.file_mode = FileDialog.FILE_MODE_SAVE_FILE

func _on_native_dialog_toggled(toggled_on: bool) -> void:
	file_dialog.use_native_dialog = toggled_on


func _on_accept_button_text_submitted(new_text: String) -> void:
	if not new_text.is_empty():
		accept_dialog.add_button(new_text, false, new_text)


func _on_accept_dialog_canceled() -> void:
	accept_dialog_output.text = "Cancelled"


func _on_accept_dialog_confirmed() -> void:
	accept_dialog_output.text = "Accepted"


func _on_accept_dialog_custom_action(action: StringName) -> void:
	accept_dialog_output.text = "Custom Action: " + action
	accept_dialog.hide()


func _on_accept_button_pressed() -> void:
	accept_dialog.show()


func _on_confirmation_button_pressed() -> void:
	confirmation_dialog.show()


func _on_confirmation_dialog_canceled() -> void:
	confirmation_dialog_output.text = "Cancelled"


func _on_confirmation_dialog_confirmed() -> void:
	confirmation_dialog_output.text = "Accepted"


func show_popup(_popup: Popup):
	var mouse_position
	if get_viewport().gui_embed_subwindows:
		mouse_position = get_global_mouse_position()
	else:
		mouse_position = DisplayServer.mouse_get_position()

	_popup.popup(Rect2(mouse_position, _popup.size))


func _on_popup_button_pressed() -> void:
	show_popup(popup)


func _on_popup_menu_button_pressed() -> void:
	show_popup(popup_menu)


func _on_popup_panel_button_pressed() -> void:
	show_popup(popup_panel)


func _on_popup_menu_option_pressed(option: String) -> void:
	popup_menu_output.text = option + " was pressed."


func _on_status_indicator_visible_toggled(toggled_on: bool) -> void:
	status_indicator.visible = toggled_on
