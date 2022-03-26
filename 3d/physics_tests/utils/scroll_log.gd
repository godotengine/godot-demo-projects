extends ScrollContainer


@export var auto_scroll: bool = false


func _process(_delta):
	if auto_scroll:
		var scrollbar = get_v_scroll_bar()
		scrollbar.value = scrollbar.max_value
