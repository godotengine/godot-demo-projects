extends Button

@export var action: String = "ui_up"

func _ready():
	assert(InputMap.has_action(action))
	set_process_unhandled_key_input(false)
	display_current_key()


func _toggled(is_button_pressed):
	set_process_unhandled_key_input(is_button_pressed)
	if is_button_pressed:
		text = "... Key"
		release_focus()
	else:
		display_current_key()


func _unhandled_key_input(event):
	# Note that you can use the _input callback instead, especially if
	# you want to work with gamepads.
	remap_action_to(event)
	button_pressed = false


func remap_action_to(event):
	# We first change the event in this game instance.
	InputMap.action_erase_events(action)
	InputMap.action_add_event(action, event)
	# And then save it to the keymaps file
	KeyPersistence.keymaps[action] = event
	KeyPersistence.save_keymap()
	text = "%s Key" % event.as_text()


func display_current_key():
	var current_key = InputMap.action_get_events(action)[0].as_text()
	text = "%s Key" % current_key
