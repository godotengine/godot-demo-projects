extends Node

# Handle the motion of both player cameras as well as communication with the
# SplitScreen shader to achieve the dynamic split screen effet
#
# Cameras are placed on the segment joining the two players, either in the middle
# if players are close enough or at a fixed distance if they are not.
# In the first case, both cameras being at the same location, only the view of
# the first one is used for the entire screen thus allowing the players to play
# on an unsplit screen.
# In the second case, the screen is split in two with a line perpendicular to the
# segment joining the two players.
#
# The points of customization are:
#   max_separation: the distance between players at which the view starts to split
#   split_line_thickness: the thickness of the split line in pixels
#   split_line_color: color of the split line
#   adaptive_split_line_thickness: if true, the split line thickness will vary
#       depending on the distance between players, with a maximum of
#       split_line_thickness. If false, the thickness will be constant and equal
#       to split_line_thickness.

export(float) var max_separation = 200.0
export(float) var split_line_thickness = 3.0
export(Color, RGBA) var split_line_color = Color.black
export(bool) var adaptive_split_line_thickness = true

onready var player1 = $"/root/Main/Game/Level/Player1"
onready var player2 = $"/root/Main/Game/Level/Player2"
onready var view = $"/root/Main/View"
onready var main_viewport = $"/root/Main/Game"
onready var viewport1 = $Viewport1
onready var viewport2 = $Viewport2
onready var camera1 = viewport1.get_node(@"Camera")
onready var camera2 = viewport2.get_node(@"Camera")


func _ready():
	viewport1.world_2d = main_viewport.world_2d
	viewport2.world_2d = main_viewport.world_2d
	_on_size_changed()
	_update_splitscreen()

	get_viewport().connect("size_changed", self, "_on_size_changed")

	view.material.set_shader_param("viewport1", viewport1.get_texture())
	view.material.set_shader_param("viewport2", viewport2.get_texture())


func _process(_delta):
	_move_cameras()
	_update_splitscreen()


func _move_cameras():
	var position_difference = _compute_position_difference_in_world()

	var distance = clamp(position_difference.length(), 0, max_separation)

	position_difference = position_difference.normalized() * distance

	camera1.position = player1.position + position_difference / 2.0
	camera2.position = player2.position - position_difference / 2.0

func _update_splitscreen():
	var screen_size = get_viewport().get_visible_rect().size
	var player1_position = (player1.position - camera1.position) / (camera1.zoom * screen_size) + Vector2(0.5, 0.5)
	var player2_position = (player2.position - camera2.position) / (camera2.zoom * screen_size) + Vector2(0.5, 0.5)

	var thickness
	if adaptive_split_line_thickness:
		var position_difference = _compute_position_difference_in_world()
		var distance = position_difference.length()
		thickness = lerp(0, split_line_thickness, (distance - max_separation) / max_separation)
		if thickness > 0:
			thickness = clamp(thickness, 1, split_line_thickness)
	else:
		thickness = split_line_thickness

	view.material.set_shader_param("split_active", _get_split_state())
	view.material.set_shader_param("player1_position", player1_position)
	view.material.set_shader_param("player2_position", player2_position)
	view.material.set_shader_param("split_line_thickness", thickness)
	view.material.set_shader_param("split_line_color", split_line_color)


# Split screen is active if players are too far apart from each other.
# Only the horizontal components (x, y) are used for distance computation
func _get_split_state():
	var position_difference = _compute_position_difference_in_world()
	var separation_distance = position_difference.length()
	return separation_distance > max_separation


func _on_size_changed():
	var screen_size = get_viewport().get_visible_rect().size

	main_viewport.size = screen_size
	viewport1.size = screen_size
	viewport2.size = screen_size

	view.material.set_shader_param("viewport_size", screen_size)


func _compute_position_difference_in_world():
	return player2.position - player1.position

