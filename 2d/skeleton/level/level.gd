extends Node2D

func _ready() -> void:
	var camera: Camera2D = find_child("Camera2D")
	var min_pos: Vector2 = $CameraLimit_min.global_position
	var max_pos: Vector2 = $CameraLimit_max.global_position
	camera.limit_left = round(min_pos.x)
	camera.limit_top = round(min_pos.y)
	camera.limit_right = round(max_pos.x)
	camera.limit_bottom = round(max_pos.y)
