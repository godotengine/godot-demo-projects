extends Control

var selected: int = 0

func _ready() -> void:
	accessibility_settings.get_subelement(0).grab_subelement_focus()

# Input:

func _gui_input(input_event: InputEvent) -> void:
	if input_event.is_action_pressed(&"ui_left"):
		selected = (selected - 1) % accessibility_settings.subelement_count
		if selected < 0:
			selected = accessibility_settings.subelement_count + selected
		queue_redraw()
		accessibility_settings.get_subelement(selected).grab_subelement_focus()
		accept_event()

	if input_event.is_action_pressed(&"ui_right"):
		selected = (selected + 1) % accessibility_settings.subelement_count
		queue_redraw()
		accessibility_settings.get_subelement(selected).grab_subelement_focus()
		accept_event()

# Draw:

func _draw() -> void:
	# Draw, provided for convenience and NOT required for screen-reader support.
	for i in range(accessibility_settings.subelement_count):
		draw_rect(accessibility_settings.get_subelement_bounds(i), Color(0.8, 0.8, 0.8, 0.5), false, 1.0)

	if has_focus():
		draw_rect(Rect2(Vector2(), get_size()), Color(0, 0, 1, 0.5), false, 3.0)
		draw_rect(accessibility_settings.get_subelement_bounds(selected), Color(0, 1, 0, 0.5), false, 2.0)
