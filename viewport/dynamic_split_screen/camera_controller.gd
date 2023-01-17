extends Node3D

# Handle the motion of both player cameras as well as communication with the
# SplitScreen shader to achieve the dynamic split screen effet
#
# Cameras are place on the segment joining the two players, either in the middle
# if players are close enough or at a fixed distance if they are not.
# In the first case, both cameras being at the same location, only the view of
# the first one is used for the entire screen thus allowing the players to play
# on a unsplit screen.
# In the second case, the screen is split in two with a line perpendicular to the
# segement joining the two players.
#
# The points of customization are:
#   max_separation: the distance between players at which the view starts to split
#   split_line_thickness: the thickness of the split line in pixels
#   split_line_color: color of the split line
#   adaptive_split_line_thickness: if true, the split line thickness will vary
#       depending on the distance between players. If false, the thickness will
#       be constant and equal to split_line_thickness

@export var max_separation: float = 20.0
@export var split_line_thickness: float = 3.0
@export var split_line_color: Color = Color.BLACK
@export var adaptive_split_line_thickness: bool = true

@onready var player1 = $"../Player1"
@onready var player2 = $"../Player2"
@onready var view = $View
@onready var viewport1 = $Viewport1
@onready var viewport2 = $Viewport2
@onready var camera1 = viewport1.get_node(^"Camera1")
@onready var camera2 = viewport2.get_node(^"Camera2")

var viewport_base_height = ProjectSettings.get_setting("display/window/size/viewport_height")

func _ready():
	_on_size_changed()
	_update_splitscreen()

	get_viewport().size_changed.connect(self._on_size_changed)

	view.material.set_shader_parameter("viewport1", viewport1.get_texture())
	view.material.set_shader_parameter("viewport2", viewport2.get_texture())


func _process(_delta):
	_move_cameras()
	_update_splitscreen()


func _move_cameras():
	var position_difference = _compute_position_difference_in_world()

	var distance = clamp(_compute_horizontal_length(position_difference), 0, max_separation)

	position_difference = position_difference.normalized() * distance

	camera1.position.x = player1.position.x + position_difference.x / 2.0
	camera1.position.z = player1.position.z + position_difference.z / 2.0

	camera2.position.x = player2.position.x - position_difference.x / 2.0
	camera2.position.z = player2.position.z - position_difference.z / 2.0


func _update_splitscreen():
	var screen_size = get_viewport().get_visible_rect().size
	var player1_position = camera1.unproject_position(player1.position) / screen_size
	var player2_position = camera2.unproject_position(player2.position) / screen_size

	var thickness
	if adaptive_split_line_thickness:
		var position_difference = _compute_position_difference_in_world()
		var distance = _compute_horizontal_length(position_difference)
		thickness = lerpf(0, split_line_thickness, (distance - max_separation) / max_separation)
		thickness = clampf(thickness, 0, split_line_thickness)
	else:
		thickness = split_line_thickness

	view.material.set_shader_parameter("split_active", _get_split_state())
	view.material.set_shader_parameter("player1_position", player1_position)
	view.material.set_shader_parameter("player2_position", player2_position)
	view.material.set_shader_parameter("split_line_thickness", thickness)
	view.material.set_shader_parameter("split_line_color", split_line_color)


# Split screen is active if players are too far apart from each other.
# Only the horizontal components (x, z) are used for distance computation
func _get_split_state():
	var position_difference = _compute_position_difference_in_world()
	var separation_distance = _compute_horizontal_length(position_difference)
	return separation_distance > max_separation


func _on_size_changed():
	var screen_size = get_viewport().get_visible_rect().size

	$Viewport1.size = screen_size
	$Viewport2.size = screen_size

	view.material.set_shader_parameter("viewport_size", screen_size)


func _compute_position_difference_in_world():
	return player2.position - player1.position


func _compute_horizontal_length(vec):
	return Vector2(vec.x, vec.z).length()
