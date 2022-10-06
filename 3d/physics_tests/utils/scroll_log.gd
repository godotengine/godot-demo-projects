extends ScrollContainer


@export var auto_scroll: bool = false


func _process(_delta):
	if auto_scroll:
		var scrollbar = get_v_scroll_bar()
		scrollbar.value = scrollbar.max_value


func _on_check_box_scroll_toggled(button_pressed):
	auto_scroll = button_pressed
