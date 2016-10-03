extends Control

#export split screen modes
export(int, "None", "Horizontal", "Vertical") var split = 1
var split_mode = -1

#split modes constants
const SPLIT_NONE = 0
const SPLIT_HORIZONTAL = 1
const SPLIT_VERTICAL = 2

#top and bottom controls
onready var top = get_node("top")
onready var bottom = get_node("bottom")

func _ready():
	#make bottom viewport have the same world2D as the top viewport, so both show the same
	get_node("bottom/viewport").set_world_2d( get_node("top/viewport").get_world_2d() )
	#make player2 camera control the offset of the bottom viewport
	get_node("top/viewport/stage/player2/camera").set_custom_viewport( get_node("bottom/viewport") )
	#
	var parallax_copy = get_node("top/viewport/stage/parallax_bg").duplicate()
	parallax_copy.set_custom_viewport( get_node("bottom/viewport") )
	get_node("top/viewport/stage").add_child(parallax_copy)
	
	#simple and alternatively, copy them to the other viewport, but they must be erased when level is unloaded
	#get_node("bottom/viewport").add_child( get_node("top/viewport/stage/parallax_bg").duplicate() )
	
	#set split screen mode for the first time
	set_split_mode(split)
	#if used inside _process/_fixed_process, the mode can be made chageable by inspector/animation key


func set_split_mode(mode):
	#change mode only if "split_mode" is different
	if mode != split_mode and mode in [0, 1, 2]:
		#get game screen size
		var screen = get_viewport().get_rect().size
		
		#changing sizes and positions
		if mode == SPLIT_HORIZONTAL:
			top.set_size(Vector2(screen.x, screen.y/2))
			top.set_pos(Vector2(0, 0))
			bottom.set_size(Vector2(screen.x, screen.y/2))
			bottom.set_pos(Vector2(0, screen.y/2))
		
		elif mode == SPLIT_VERTICAL:
			top.set_size(Vector2(screen.x/2, screen.y))
			top.set_pos(Vector2(0, 0))
			bottom.set_size(Vector2(screen.x/2, screen.y))
			bottom.set_pos(Vector2(screen.x/2, 0))
		
		elif mode == SPLIT_NONE:
			top.set_size(Vector2(screen.x, screen.y))
			top.set_pos(Vector2(0, 0))
			bottom.set_hidden(true)
		
		if split_mode == SPLIT_NONE:
			bottom.set_hidden(false)
		#apply mode
		split_mode = mode
