extends ScrollContainer


@export var auto_scroll = false


func _ready():
	var scrollbar = get_v_scroll_bar()
	scrollbar.connect(&"scrolling", Callable(self, "_on_scrolling"))


func _process(_delta):
	if auto_scroll:
		var scrollbar = get_v_scroll_bar()
		scrollbar.value = scrollbar.max_value


func _on_scrolling():
	auto_scroll = false
	$"../CheckBoxScroll".pressed = false
