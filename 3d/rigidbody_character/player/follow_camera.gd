extends Camera3D

var collision_exception := []
var max_height := 2.0
var min_height := 0

@export var min_distance := 0.5
@export var max_distance := 3.0
@export var angle_v_adjust := 0.0
@onready var target_node: Node3D = get_parent()

func _ready() -> void:
	collision_exception.append(target_node.get_parent().get_rid())
	# Detach the camera transform from the parent spatial node.
	top_level = true


func _physics_process(_delta: float) -> void:
	var target_pos := target_node.global_transform.origin
	var camera_pos := global_transform.origin

	var delta_pos := camera_pos - target_pos

	# Regular delta follow.

	# Check ranges.
	if delta_pos.length() < min_distance:
		delta_pos = delta_pos.normalized() * min_distance
	elif delta_pos.length() > max_distance:
		delta_pos = delta_pos.normalized() * max_distance

	# Check upper and lower height.
	delta_pos.y = clamp(delta_pos.y, min_height, max_height)
	camera_pos = target_pos + delta_pos

	look_at_from_position(camera_pos, target_pos, Vector3.UP)

	# Turn a little up or down.
	var t := transform
	t.basis = Basis(t.basis[0], deg_to_rad(angle_v_adjust)) * t.basis
	transform = t
