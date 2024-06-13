class_name MySV
extends SubViewportContainer
## Input Routing for different SubViewports.
#
## Based on the provided input configuration, ensures only the correct
## events reaching the SubViewport-


var _current_keyboard_set: Array = [] # Currently used keyboard set.
var _current_joypad_device: int = -1 # Currently used joypad device id.


# Make sure, that only the events are sent to the SubViewport,
# that are allowed via the OptionButton selection.
func _propagate_input_event(event: InputEvent) -> bool:
	if event is InputEventKey:
		if _current_keyboard_set.has(event.keycode):
			return true
	elif event is InputEventJoypadButton:
		if _current_joypad_device > -1 and event.device == _current_joypad_device:
			return true
	return false


# Set new config for input handling.
func set_input_config(config: Dictionary):
	_current_keyboard_set = config["keyboard"]
	_current_joypad_device = config["joypad"]
