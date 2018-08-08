extends Node

func _ready():
	# step one: consistent world
	# we want both viewports to use the same world
	$SecondScreen/Viewport.world_2d = $ActualGame/Viewport.world_2d

	# step two: second camera renders to second viewport
	# this is the "two current cameras in one scene" trick
	# each camera controls the scroll offset of a different viewport
	$ActualGame/Viewport/stage/player2/camera.custom_viewport = $SecondScreen/Viewport

	# step three: other canvas layers (i.e. parallax backgrounds)
	var parallax_copy = $ActualGame/Viewport/stage/parallax_bg.duplicate()
	parallax_copy.custom_viewport = $SecondScreen/Viewport
	$ActualGame/Viewport/stage.add_child(parallax_copy)

	# you can instead add the copy to the second viewport and skip setting a custom viewport,
	# but you have to remember to remove them when you want to unload the level
	# $SecondScreen/Viewport.add_child($ActualGame/Viewport/stage/parallax_bg.duplicate())
