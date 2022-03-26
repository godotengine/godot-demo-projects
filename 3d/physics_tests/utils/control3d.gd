extends Control


@export var world_offset = Vector3.ZERO

var _pos_offset
var _attachment


func _ready():
	_pos_offset = position
	_attachment = get_parent() as Node3D


func _process(_delta):
	if _attachment == null:
		return

	var viewport = get_viewport()
	if viewport == null:
		return

	var camera = viewport.get_camera_3d()
	if camera == null:
		return

	var world_pos = world_offset + _attachment.global_transform.origin
	var screen_pos = camera.unproject_position(world_pos)

	position = _pos_offset + screen_pos - 0.5 * size
