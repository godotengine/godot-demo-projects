extends Control

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
	pass
