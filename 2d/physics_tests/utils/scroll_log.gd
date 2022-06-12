extends ScrollContainer


export(bool) var auto_scroll = false setget set_auto_scroll


func _ready():
	var scrollbar = get_v_scrollbar()
	scrollbar.connect("scrolling", self, "_on_scrolling")


func _process(_delta):
	if auto_scroll:
		var scrollbar = get_v_scrollbar()
		scrollbar.value = scrollbar.max_value


func set_auto_scroll(value):
	auto_scroll = value


func _on_scrolling():
	auto_scroll = false
	$"../CheckBoxScroll".pressed = false
