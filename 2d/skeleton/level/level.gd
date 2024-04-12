extends Node2D

func _ready():
	var camera = find_child("Camera2D")
	var min_pos = $CameraLimit_min.global_position
	var max_pos = $CameraLimit_max.global_position
	camera.limit_left = min_pos.x
	camera.limit_top = min_pos.y
	camera.limit_right = max_pos.x
	camera.limit_bottom = max_pos.y
