extends Button

export(String) var action = "ui_up"

func _ready():
	assert(InputMap.has_action(action))
	set_process_unhandled_key_input(false)
	display_current_key()


func _toggled(button_pressed):
	set_process_unhandled_key_input(button_pressed)
	if button_pressed:
		text = "... Key"
		release_focus()
	else:
		display_current_key()


func _unhandled_key_input(event):
	# Note that you can use the _input callback instead, especially if
	# you want to work with gamepads.
	remap_action_to(event)
	pressed = false


func remap_action_to(event):
	InputMap.action_erase_events(action)
	InputMap.action_add_event(action, event)
	text = "%s Key" % event.as_text()


func display_current_key():
	var current_key = InputMap.get_action_list(action)[0].as_text()
	text = "%s Key" % current_key
