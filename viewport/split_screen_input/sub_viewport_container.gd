## Input Routing for different SubViewports.
## Based on the provided input configuration, ensures only the correct
## events reaching the SubViewport.
class_name InputRoutingViewportContainer
extends SubViewportContainer


var _current_keyboard_set: Array = [] # Currently used keyboard set.
var _current_joypad_device: int = -1 # Currently used joypad device id.


# Make sure, that only the events are sent to the SubViewport,
# that are allowed via the OptionButton selection.
func _propagate_input_event(input_event: InputEvent) -> bool:
	if input_event is InputEventKey:
		if _current_keyboard_set.has(input_event.keycode):
			return true
	elif input_event is InputEventJoypadButton:
		if _current_joypad_device > -1 and input_event.device == _current_joypad_device:
			return true
	return false


# Set new config for input handling.
func set_input_config(config_dict: Dictionary):
	_current_keyboard_set = config_dict["keyboard"]
	_current_joypad_device = config_dict["joypad"]
