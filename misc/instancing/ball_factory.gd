extends Node2D

export(PackedScene) var ball_scene = preload("res://ball.tscn")

func _unhandled_input(event):
	if event.is_echo():
		return
	if event is InputEventMouseButton and event.is_pressed():
		if event.button_index == BUTTON_LEFT:
			spawn(get_global_mouse_position())


func spawn(spawn_global_position):
	var instance = ball_scene.instance()
	instance.global_position = spawn_global_position
	add_child(instance)
