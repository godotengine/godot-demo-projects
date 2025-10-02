## Interface for a SplitScreen
class_name SplitScreen
extends Node


const JOYPAD_PREFIX: String = "Joypad"

@export var init_position := Vector2.ZERO

var _keyboard_options: Dictionary # Copy of all keyboard options.

@onready var opt: OptionButton = $OptionButton
@onready var viewport: SubViewport = $InputRoutingViewportContainer/SubViewport
@onready var input_router: InputRoutingViewportContainer = $InputRoutingViewportContainer
@onready var play: Player = $InputRoutingViewportContainer/SubViewport/Player


# Set the configuration of this split screen and perform OptionButton initialization.
func set_config(config_dict: Dictionary):
	_keyboard_options = config_dict["keyboard"]
	play.position = config_dict["position"]
	var local_index: int = config_dict["index"]
	play.modulate = config_dict["color"]
	opt.clear()
	for keyboard_opt in _keyboard_options:
		opt.add_item(keyboard_opt)
	for index in config_dict["joypads"]:
		opt.add_item("%s %s" % [JOYPAD_PREFIX, index + 1])
	opt.select(local_index)
	_on_option_button_item_selected(local_index)
	viewport.world_2d = config_dict["world"] # Connect all Split Screens to the same World2D.


# Update Keyboard Settings after selecting them in the OptionButton.
func _on_option_button_item_selected(index: int) -> void:
	var text: String = opt.get_item_text(index)
	if text.begins_with(JOYPAD_PREFIX):
		input_router.set_input_config({"joypad": text.substr(text.length() - 1, -1).to_int(), "keyboard": []})
	else:
		input_router.set_input_config({"keyboard": _keyboard_options[text]["keys"], "joypad": -1})
