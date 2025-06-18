class_name SplitScreen
extends Node
## Interface for a SplitScreen


const keypad_string:String = "Joypad" # Prefix for joypads.

@export var init_position: Vector2

var _keyboard_options: Dictionary # Copy of all keyboard options.

@onready var opt: OptionButton = $OptionButton
@onready var v: SubViewport = $SubViewportContainer/SubViewport
@onready var svc: MySV = $SubViewportContainer
@onready var play: Player = $SubViewportContainer/SubViewport/Player


# Set the configuration of this split screen and perform OptionButton initialization.
func set_config(c: Dictionary):
	_keyboard_options = c["keyboard"]
	play.position = c["position"]
	var local_index = c["index"]
	play.modulate = c["color"]
	opt.clear()
	for k in _keyboard_options:
		opt.add_item(k)
	for i in c["joypads"]:
		opt.add_item("%s %s" % [keypad_string, i+1])
	opt.select(local_index)
	_on_option_button_item_selected(local_index)
	v.world_2d = c["world"] # Connect all Split Screens to the same World2D.


# Update Keyboard Settings after selecting them in the OptionButton.
func _on_option_button_item_selected(index: int) -> void:
	var txt: String = opt.get_item_text(index)
	if txt.begins_with(keypad_string):
		svc.set_input_config({"joypad": txt.substr(txt.length()-1, -1).to_int(), "keyboard": []})
	else:
		svc.set_input_config({"keyboard": _keyboard_options[txt]["keys"], "joypad": -1})
