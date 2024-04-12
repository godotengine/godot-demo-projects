extends ScrollContainer


@export var auto_scroll = false


func _ready():
	var scrollbar = get_v_scroll_bar()
	scrollbar.scrolling.connect(_on_scrolling)


func _process(_delta):
	if auto_scroll:
		var scrollbar = get_v_scroll_bar()
		scrollbar.value = scrollbar.max_value


func _on_scrolling():
	auto_scroll = false
	$"../CheckBoxScroll".button_pressed = false


func _on_check_box_scroll_toggled(button_pressed):
	auto_scroll = button_pressed
