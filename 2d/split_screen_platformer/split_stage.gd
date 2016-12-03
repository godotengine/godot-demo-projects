tool
extends Control

#export split screen modes
#if used with setget, the mode can be made chageable by inspector/animation key
export(int, "None", "Horizontal", "Vertical") var split_mode = 1 setget set_split_mode

#other split_mode variable to check previous mode on split_mode set method
var _split_mode = -1

#split modes constants
const SPLIT_NONE = 0
const SPLIT_HORIZONTAL = 1
const SPLIT_VERTICAL = 2


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
	
	#setting split mode for the first time if node is ready
	set_split_mode(split_mode)


func set_split_mode(mode):
	split_mode = mode
	if get_viewport() != null:
		#apply mode
		_set_split_mode()


func _set_split_mode():
	#change mode only if "_split_mode" is different
	if _split_mode != split_mode:
		#get game screen size
		var screen = get_size()
		
		#changing sizes and positions
		if split_mode == SPLIT_HORIZONTAL:
			get_node("top").set_size(Vector2(screen.x, screen.y/2))
			get_node("top").set_pos(Vector2(0, 0))
			get_node("bottom").set_size(Vector2(screen.x, screen.y/2))
			get_node("bottom").set_pos(Vector2(0, screen.y/2))
		
		elif split_mode == SPLIT_VERTICAL:
			get_node("top").set_size(Vector2(screen.x/2, screen.y))
			get_node("top").set_pos(Vector2(0, 0))
			get_node("bottom").set_size(Vector2(screen.x/2, screen.y))
			get_node("bottom").set_pos(Vector2(screen.x/2, 0))
		
		elif split_mode == SPLIT_NONE:
			get_node("top").set_size(Vector2(screen.x, screen.y))
			get_node("top").set_pos(Vector2(0, 0))
			get_node("bottom").set_hidden(true)
		
		if _split_mode == SPLIT_NONE:
			get_node("bottom").set_hidden(false)
		
		_split_mode = split_mode
