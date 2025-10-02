extends Node2D

@export var ball_scene: PackedScene = preload("res://ball.tscn")

func _unhandled_input(event: InputEvent) -> void:
	if event.is_echo():
		return

	if event is InputEventMouseButton and event.is_pressed():
		if event.button_index == MOUSE_BUTTON_LEFT:
			spawn(get_global_mouse_position())


func spawn(spawn_global_position: Vector2) -> void:
	var instance: Node2D = ball_scene.instantiate()
	instance.global_position = spawn_global_position
	add_child(instance)
