extends Control

var item_aes : Array[RID] = [RID(), RID(), RID()]
var item_names : Array[String] = ["Item 1", "Item 2", "Item 3"]
var item_values : Array[int] = [0, 0, 0]
var item_rects : Array[Rect2] = [Rect2(0, 0, 40, 40), Rect2(40, 0, 40, 40), Rect2(80, 0, 40, 40)]
var selected : int = 0

# Input:

func _gui_input(event: InputEvent) -> void:
	if event.is_action_pressed(&"ui_left"):
		selected = (selected - 1) % item_aes.size()
		queue_redraw()
		queue_accessibility_update() # Request node accessibility information update. Similar to "queue_redraw" for drawing.
		accept_event()

	if event.is_action_pressed(&"ui_right"):
		selected = (selected + 1) % item_aes.size()
		queue_redraw()
		queue_accessibility_update()
		accept_event()

	if event.is_action_pressed(&"ui_up"):
		item_values[selected] = clamp(item_values[selected] - 1, -100, 100)
		queue_redraw()
		queue_accessibility_update()
		accept_event()

	if event.is_action_pressed(&"ui_down"):
		item_values[selected] = clamp(item_values[selected] + 1, -100, 100)
		queue_redraw()
		queue_accessibility_update()
		accept_event()

# Accessibility actions and focus callback:

func _accessibility_action_dec(_data: Variant, item: int) -> void:
	# Numeric value decrement, "data" is not used for this action.
	item_values[item] = clamp(item_values[item] - 1, -100, 100)
	queue_redraw()
	queue_accessibility_update()


func _accessibility_action_inc(_data: Variant, item: int) -> void:
	# Numeric value increment, "data" is not used for this action.
	item_values[item] = clamp(item_values[item] + 1, -100, 100)
	queue_redraw()
	queue_accessibility_update()


func _accessibility_action_set_num_value(data: Variant, item: int) -> void:
	# Numeric value set, "data" is a new value.
	item_values[item] = clamp(data, -100, 100)
	queue_redraw()
	queue_accessibility_update()


func _get_focused_accessibility_element() -> RID:
	# Return focused sub-element, if no sub-element is focused, return base element (value returned by "get_accessibility_element") instead.
	return item_aes[selected]

# Notifications handler:

func _notification(what: int) -> void:
	if what == NOTIFICATION_ACCESSIBILITY_INVALIDATE:
		# Accessibility cleanup:
		#
		# Called when existing main element is destroyed.

		# Note: since item sub-elements are children of the main element, there's no need to destroy them manually. But we should keep track when handles are invalidated.
		for i in range(item_aes.size()):
			item_aes[i] = RID()


	if what == NOTIFICATION_ACCESSIBILITY_UPDATE:
		# Accessibility update handler:
		#
		# This function acts as an alternative "draw" for the screen reader, and provides information about this node.

		var ae : RID = get_accessibility_element() # Get handle to the accessibilty element, accessibilty element is created and destroyed automatically.

		# Set role of the element.
		DisplayServer.accessibility_update_set_role(ae, DisplayServer.ROLE_LIST_BOX)

		# Set other properties.
		DisplayServer.accessibility_update_set_list_item_count(ae, item_aes.size())
		DisplayServer.accessibility_update_set_name(ae, "List")

		for i in range(item_aes.size()):
			# Create a new sub-element for the item if it doesn't exist.
			if not item_aes[i].is_valid():
				item_aes[i] = DisplayServer.accessibility_create_sub_element(ae, DisplayServer.ROLE_LIST_BOX_OPTION)

			# Sub-element properties.
			DisplayServer.accessibility_update_set_list_item_index(item_aes[i], i)
			DisplayServer.accessibility_update_set_list_item_selected(item_aes[i], selected == i)
			DisplayServer.accessibility_update_set_name(item_aes[i], item_names[i]) # Readable name.
			DisplayServer.accessibility_update_set_value(item_aes[i], str(item_values[i])) # Readable value.

			# Numeric value info for the actions.
			DisplayServer.accessibility_update_set_num_value(item_aes[i], item_values[i]);
			DisplayServer.accessibility_update_set_num_range(item_aes[i], -100, 100);
			DisplayServer.accessibility_update_set_num_step(item_aes[i], 1)

			# Sub-element bounding box, relative to the parent element.
			DisplayServer.accessibility_update_set_bounds(item_aes[i], item_rects[i])

			# Set supported actions for the item, actions can be invoked directly by the screen-reader (e.g, via global keyboard shortcuts).
			DisplayServer.accessibility_update_add_action(item_aes[i], DisplayServer.ACTION_DECREMENT, _accessibility_action_dec.bind(i))
			DisplayServer.accessibility_update_add_action(item_aes[i], DisplayServer.ACTION_INCREMENT, _accessibility_action_inc.bind(i))
			DisplayServer.accessibility_update_add_action(item_aes[i], DisplayServer.ACTION_SET_VALUE, _accessibility_action_set_num_value.bind(i))

	if what == NOTIFICATION_FOCUS_ENTER or what == NOTIFICATION_FOCUS_EXIT:
		queue_redraw()

# Draw:

func _draw() -> void:
	# Draw, provided for convenience and NOT required for screen-reader support.
	for i in range(item_aes.size()):
		draw_rect(item_rects[selected], Color(0.8, 0.8, 0.8, 0.5), false, 1)
		draw_string(get_theme_font("font"), item_rects[i].position + Vector2(0, 30), str(item_values[i]), HORIZONTAL_ALIGNMENT_CENTER, 40)

	if has_focus():
		draw_rect(Rect2(Vector2(), get_size()), Color(0, 0, 1, 0.5), false, 3)
		draw_rect(item_rects[selected], Color(0, 1, 0, 0.5), false, 2)
