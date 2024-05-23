extends Button

@export var action := "ui_up"

func _ready() -> void:
	assert(InputMap.has_action(action))
	set_process_unhandled_key_input(false)
	display_current_key()


func _toggled(is_button_pressed: bool) -> void:
	set_process_unhandled_key_input(is_button_pressed)
	if is_button_pressed:
		text = "<press a key>"
		modulate = Color.YELLOW
		release_focus()
	else:
		display_current_key()
		modulate = Color.WHITE
		# Grab focus after assigning a key, so that you can go to the next
		# key using the keyboard.
		grab_focus()


# NOTE: You can use the `_input()` callback instead, especially if
# you want to work with gamepads.
func _unhandled_key_input(event: InputEvent) -> void:
	# Skip if pressing Enter, so that the input mapping GUI can be navigated
	# with the keyboard. The downside of this approach is that the Enter
	# key can't be bound to actions.
	if event is InputEventKey and event.keycode != KEY_ENTER:
		remap_action_to(event)
		button_pressed = false


func remap_action_to(event: InputEvent) -> void:
	# We first change the event in this game instance.
	InputMap.action_erase_events(action)
	InputMap.action_add_event(action, event)
	# And then save it to the keymaps file.
	KeyPersistence.keymaps[action] = event
	KeyPersistence.save_keymap()
	text = event.as_text()


func display_current_key() -> void:
	var current_key := InputMap.action_get_events(action)[0].as_text()
	text = current_key
