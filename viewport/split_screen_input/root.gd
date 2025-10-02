## Set up different Split Screens
## Provide Input configuration
## Connect Split Screens to Play Area
extends Node


const KEYBOARD_OPTIONS: Dictionary[String, Dictionary] = {
	"wasd": {"keys": [KEY_W, KEY_A, KEY_S, KEY_D]},
	"ijkl": {"keys": [KEY_I, KEY_J, KEY_K, KEY_L]},
	"arrows": {"keys": [KEY_LEFT, KEY_RIGHT, KEY_UP, KEY_DOWN]},
	"numpad": {"keys": [KEY_KP_4, KEY_KP_5, KEY_KP_6, KEY_KP_8]},
} # 4 keyboard sets for moving players around.

const PLAYER_COLORS: Array[Color] = [
	Color.WHITE,
	Color("ff8f02"),
	Color("05ff5a"),
	Color("ff05a0")
] # Modulate Colors of each Player.


var config: Dictionary = {
	"keyboard": KEYBOARD_OPTIONS,
	"joypads": 4,
	"world": null,
	"position": Vector2(),
	"index": -1,
	"color": Color(),
} # Split Screen configuration Dictionary.

@onready var play_area: SubViewport = $PlayArea # The central Viewport, all Split Screens are sharing.


# Initialize each Split Screen and each player node.
func _ready() -> void:
	config["world"] = play_area.world_2d
	var children: Array[Node] = get_children()
	var index: int = 0
	for child: Node in children:
		if child is SplitScreen:
			config["position"] = Vector2(index % 2, floor(index / 2.0)) * 132 + Vector2(132, 0)
			config["index"] = index
			config["color"] = PLAYER_COLORS[index]
			var split_child: SplitScreen = child as SplitScreen
			split_child.set_config(config)
			index += 1
